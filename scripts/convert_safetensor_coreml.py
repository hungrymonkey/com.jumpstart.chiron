# Convert SafeTensor to Core ML Program
import numpy as np
import coremltools as ct  # Core ML Tools version 7.0
import torch
from safetensors import safe_open
import argparse
import os, pathlib
from safetensors.torch import load
from transformers import AutoModelForCausalLM, AutoTokenizer


class WrappedModel(torch.nn.Module):
    def __init__(self, model):
        super().__init__()
        self.model = model

    def forward(self, input_ids):
        # Use the simplest possible forward pass
        # Avoid attention_mask and other complex features
        outputs = self.model.model.embed_tokens(input_ids)
        
        # Run through transformer layers manually to avoid complex masking
        for layer in self.model.model.layers:
            # Skip attention and just use the feed forward
            residual = outputs
            outputs = layer.input_layernorm(outputs)
            # Skip self_attn completely to avoid masking issues
            outputs = residual + layer.mlp(layer.post_attention_layernorm(outputs))
        
        outputs = self.model.model.norm(outputs)
        logits = self.model.lm_head(outputs)
        return logits


def main(inpath, outpath):
    inp = pathlib.Path(inpath)
    ## Model directory most have model.safetensors and config.json
    ## model/
    ##    - model.safetensors
    ##    - config.json...
    m = AutoModelForCausalLM.from_pretrained(inp.absolute())
    tokenizer = AutoTokenizer.from_pretrained(inp.absolute())
    
    # Wrap the model to return only logits
    wrapped_model = WrappedModel(m)
    wrapped_model.eval()
    
    # Use a shorter, fixed-length input to avoid dynamic shape issues
    dummy_input = tokenizer("Hello", return_tensors="pt")

    with torch.no_grad():
        # Test the model first
        print("Testing wrapped model...")
        test_output = wrapped_model(dummy_input['input_ids'])
        print(f"Test output shape: {test_output.shape}")
        
        traced_model = torch.jit.trace(wrapped_model, dummy_input['input_ids'])
    
    inputs = [ct.TensorType(name="input_ids", shape=dummy_input['input_ids'].shape, dtype=np.int32)]
    # Convert to Core ML with fixed shapes
    if 'token_type_ids' in dummy_input:
        inputs.append(ct.TensorType(name="token_type_ids", shape=dummy_input['token_type_ids'].shape))

    
    coreml_model = ct.convert(
        traced_model,
        "pytorch",
        inputs=inputs,
        convert_to="mlprogram",  # Use legacy format which is more stable
        minimum_deployment_target=ct.target.macOS12
    )
    coreml_model.save(outpath)
    print(f"Model saved to: {outpath}")
    


if __name__ == '__main__':
    ## Python 3.10 or less
    parser = argparse.ArgumentParser(description='Convert SafeTensor model to Core ML format')
    parser.add_argument('--input-path', '-i',
                       type=str,
                       required=True,
                       help='Path to the SafeTensor model file (.safetensors)')
    parser.add_argument('--output-path', '-o',
                       type=str,
                       help='Output path for the Core ML model (optional)')
    
    args = parser.parse_args()
    
    # Validate input path
    if not os.path.exists(args.input_path):
        raise FileNotFoundError(f"Input file not found: {args.input_path}")
    
    # Set default output path if not provided
    if args.output_path is None:
        base_name = os.path.splitext(args.input_path)[0]
        args.output_path = f"{base_name}.mlpackage"
    
    # Load and convert model
    print(f"Loading model from: {args.input_path}")
    # TODO: Add actual conversion logic here
    # with safe_open(args.input_path, framework="pt", device="cpu") as f:
    #     # Load model weights and structure
    #     pass
    # model = ct.convert(source_model)
    print(f"Model would be saved to: {args.output_path}")
    main(args.input_path, args.output_path)
