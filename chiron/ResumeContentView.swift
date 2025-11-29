import SwiftUI

struct ResumeContentView: View {
    @Binding var isEditing: Bool
    @Binding var resumeData: ResumeData
    @Binding var educationEntries: [EducationData]
    @Binding var experienceEntries: [ExperienceData]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if isEditing {
                    editableResumeSection
                    editableEducationSection
                    editableExperienceSection
                } else {
                    displayResumeSection
                    displayEducationSection
                    displayExperienceSection
                }
            }
            .padding()
        }
    }
    
    private var displayResumeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Resume Information")
                .font(.headline)
                .padding(.bottom, 5)
            
            if !resumeData.title.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Title: \(resumeData.title)")
                        .font(.subheadline)
                    
                    if !resumeData.phone.isEmpty {
                        Text("Phone: \(resumeData.phone)")
                            .font(.subheadline)
                    }
                    
                    if !resumeData.address.isEmpty {
                        Text("Address: \(resumeData.address)")
                            .font(.subheadline)
                    }
                    
                    if !resumeData.website.isEmpty {
                        Text("Website: \(resumeData.website)")
                            .font(.subheadline)
                    }
                    
                    if !resumeData.summary.isEmpty {
                        Text("Summary:")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Text(resumeData.summary)
                            .font(.body)
                            .padding(.leading, 10)
                    }
                }
            } else {
                Text("No resume information available. Click 'Edit Resume' to add your details.")
                    .foregroundColor(.secondary)
                    .italic()
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
    
    private var editableResumeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Resume Information")
                .font(.headline)
                .padding(.bottom, 5)
            
            VStack(spacing: 8) {
                TextField("Resume Title", text: $resumeData.title)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                TextField("Phone", text: $resumeData.phone)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                TextField("Address", text: $resumeData.address)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                TextField("Website", text: $resumeData.website)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                VStack(alignment: .leading) {
                    Text("Summary")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    TextEditor(text: $resumeData.summary)
                        .frame(minHeight: 80)
                        .padding(8)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
    
    private var displayEducationSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Education")
                .font(.headline)
            
            if educationEntries.isEmpty {
                Text("No education information available.")
                    .foregroundColor(.secondary)
                    .italic()
            } else {
                ForEach(Array(educationEntries.indices), id: \.self) { index in
                    let education = educationEntries[index]
                    VStack(alignment: .leading, spacing: 6) {
                        Text(education.institution)
                            .font(.headline)
                        
                        if !education.degree.isEmpty {
                            Text("\(education.degree)")
                                .font(.subheadline)
                        }
                        
                        if !education.fieldOfStudy.isEmpty {
                            Text("Field: \(education.fieldOfStudy)")
                                .font(.caption)
                        }
                        
                        if !education.startDate.isEmpty || !education.endDate.isEmpty {
                            Text("\(education.startDate) - \(education.endDate)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        if !education.description.isEmpty {
                            Text(education.description)
                                .font(.body)
                                .padding(.top, 4)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color(NSColor.controlBackgroundColor))
                    .cornerRadius(8)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
    
    private var editableEducationSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Education")
                    .font(.headline)
                Spacer()
                Button("Add Education") {
                    educationEntries.append(EducationData())
                }
                .buttonStyle(.bordered)
            }
            
            ForEach(Array(educationEntries.indices), id: \.self) { index in
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Education \(index + 1)")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Spacer()
                        Button("Remove") {
                            educationEntries.remove(at: index)
                        }
                        .foregroundColor(.red)
                        .font(.caption)
                    }
                    
                    VStack(spacing: 8) {
                        TextField("Institution", text: $educationEntries[index].institution)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        TextField("Degree", text: $educationEntries[index].degree)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        TextField("Field of Study", text: $educationEntries[index].fieldOfStudy)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        HStack {
                            TextField("Start Date", text: $educationEntries[index].startDate)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            TextField("End Date", text: $educationEntries[index].endDate)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        
                        VStack(alignment: .leading) {
                            Text("Description")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            TextEditor(text: $educationEntries[index].description)
                                .frame(minHeight: 60)
                                .padding(4)
                                .background(Color(NSColor.controlBackgroundColor))
                                .cornerRadius(6)
                        }
                    }
                }
                .padding()
                .background(Color(NSColor.controlBackgroundColor))
                .cornerRadius(8)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
    
    private var displayExperienceSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Experience")
                .font(.headline)
            
            if experienceEntries.isEmpty {
                Text("No work experience available.")
                    .foregroundColor(.secondary)
                    .italic()
            } else {
                ForEach(Array(experienceEntries.indices), id: \.self) { index in
                    let experience = experienceEntries[index]
                    VStack(alignment: .leading, spacing: 6) {
                        Text(experience.company)
                            .font(.headline)
                        
                        Text(experience.position)
                            .font(.subheadline)
                            .foregroundColor(.blue)
                        
                        if !experience.location.isEmpty {
                            Text("Location: \(experience.location)")
                                .font(.caption)
                        }
                        
                        if !experience.startDate.isEmpty || !experience.endDate.isEmpty {
                            Text("\(experience.startDate) - \(experience.endDate)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        if !experience.description.isEmpty {
                            Text(experience.description)
                                .font(.body)
                                .padding(.top, 4)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color(NSColor.controlBackgroundColor))
                    .cornerRadius(8)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
    
    private var editableExperienceSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Experience")
                    .font(.headline)
                Spacer()
                Button("Add Experience") {
                    experienceEntries.append(ExperienceData())
                }
                .buttonStyle(.bordered)
            }
            
            ForEach(Array(experienceEntries.indices), id: \.self) { index in
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Experience \(index + 1)")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Spacer()
                        Button("Remove") {
                            experienceEntries.remove(at: index)
                        }
                        .foregroundColor(.red)
                        .font(.caption)
                    }
                    
                    VStack(spacing: 8) {
                        TextField("Company", text: $experienceEntries[index].company)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        TextField("Position", text: $experienceEntries[index].position)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        TextField("Location", text: $experienceEntries[index].location)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        HStack {
                            TextField("Start Date", text: $experienceEntries[index].startDate)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            TextField("End Date", text: $experienceEntries[index].endDate)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        
                        VStack(alignment: .leading) {
                            Text("Description")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            TextEditor(text: $experienceEntries[index].description)
                                .frame(minHeight: 60)
                                .padding(4)
                                .background(Color(NSColor.controlBackgroundColor))
                                .cornerRadius(6)
                        }
                    }
                }
                .padding()
                .background(Color(NSColor.controlBackgroundColor))
                .cornerRadius(8)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

#Preview {
    @State var isEditing = false
    @State var resumeData = ResumeData()
    @State var educationEntries: [EducationData] = []
    @State var experienceEntries: [ExperienceData] = []
    
    return ResumeContentView(
        isEditing: $isEditing,
        resumeData: $resumeData,
        educationEntries: $educationEntries,
        experienceEntries: $experienceEntries
    )
}