import SwiftUI

struct ResumeData {
    var id: Int?
    var title: String = ""
    var summary: String = ""
    var phone: String = ""
    var address: String = ""
    var website: String = ""
}

struct EducationData {
    var id: Int?
    var institution: String = ""
    var degree: String = ""
    var fieldOfStudy: String = ""
    var startDate: String = ""
    var endDate: String = ""
    var description: String = ""
}

struct ExperienceData {
    var id: Int?
    var company: String = ""
    var position: String = ""
    var startDate: String = ""
    var endDate: String = ""
    var description: String = ""
    var location: String = ""
}

struct HomeView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var isEditing = false
    @State private var resumeData = ResumeData()
    @State private var originalResumeData = ResumeData()
    @State private var educationEntries: [EducationData] = []
    @State private var originalEducationEntries: [EducationData] = []
    @State private var experienceEntries: [ExperienceData] = []
    @State private var originalExperienceEntries: [ExperienceData] = []
    @State private var showingSaveAlert = false
    @State private var saveMessage = ""
    
    private let dbManager = SQLiteManager.shared
    
    var body: some View {
        TabView {
            NavigationView {
                
                ScrollView {
                    VStack(spacing: 20) {
                        if let user = authManager.currentUser {
                            headerSection(user: user)
                            
                        }
                    }
                    .padding()
                }
                ResumeContentView(
                    isEditing: $isEditing,
                    resumeData: $resumeData,
                    educationEntries: $educationEntries,
                    experienceEntries: $experienceEntries
                )
                .navigationTitle("My Resume")
                .onAppear {
                    loadResumeData()
                }
                .alert("Save Result", isPresented: $showingSaveAlert) {
                    Button("OK", role: .cancel) { }
                } message: {
                    Text(saveMessage)
                }
            }
            .tabItem {
                Image(systemName: "house.fill")
                Text("Home")
            }
            
            ProfileView()
                .environmentObject(authManager)
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Profile")
                }
            
            SettingsView()
                .environmentObject(authManager)
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
        }
    }
    
    private func headerSection(user: User) -> some View {
        VStack(spacing: 15) {
            Text("Welcome back, \(user.name)!")
                .font(.title)
                .fontWeight(.bold)
            
            HStack(spacing: 15) {
                if isEditing {
                    Button("Save Changes") {
                        saveResumeData()
                    }
                    .buttonStyle(.borderedProminent)
                    
                    Button("Discard Changes") {
                        discardChanges()
                    }
                    .buttonStyle(.bordered)
                    .foregroundColor(.red)
                } else {
                    Button("Edit Resume") {
                        startEditing()
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
    
    private var resumeContentSection: some View {
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
    
    private func loadResumeData() {
        guard let user = authManager.currentUser else { return }
        
        let resumes = dbManager.getResumesByUserId(user.id)
        if let resume = resumes.first {
            resumeData = ResumeData(
                id: resume.id,
                title: resume.title,
                summary: resume.summary ?? "",
                phone: resume.phone ?? "",
                address: resume.address ?? "",
                website: resume.website ?? ""
            )
            
            let education = dbManager.getEducationByResumeId(resume.id)
            educationEntries = education.map { edu in
                EducationData(
                    id: edu.id,
                    institution: edu.institution,
                    degree: edu.degree ?? "",
                    fieldOfStudy: edu.fieldOfStudy ?? "",
                    startDate: edu.startDate ?? "",
                    endDate: edu.endDate ?? "",
                    description: edu.description ?? ""
                )
            }
            
            let experience = dbManager.getExperienceByResumeId(resume.id)
            experienceEntries = experience.map { exp in
                ExperienceData(
                    id: exp.id,
                    company: exp.company,
                    position: exp.position,
                    startDate: exp.startDate ?? "",
                    endDate: exp.endDate ?? "",
                    description: exp.description ?? "",
                    location: exp.location ?? ""
                )
            }
        }
        
        saveOriginalData()
    }
    
    private func saveOriginalData() {
        originalResumeData = resumeData
        originalEducationEntries = educationEntries
        originalExperienceEntries = experienceEntries
    }
    
    private func startEditing() {
        saveOriginalData()
        isEditing = true
    }
    
    private func discardChanges() {
        resumeData = originalResumeData
        educationEntries = originalEducationEntries
        experienceEntries = originalExperienceEntries
        isEditing = false
    }
    
    private func saveResumeData() {
        guard let user = authManager.currentUser else {
            saveMessage = "Error: No user logged in"
            showingSaveAlert = true
            return
        }
        
        var resumeId: Int
        
        if let existingId = resumeData.id {
            resumeId = existingId
        } else {
            let success = dbManager.insertResume(
                userId: user.id,
                title: resumeData.title,
                summary: resumeData.summary.isEmpty ? nil : resumeData.summary,
                phone: resumeData.phone.isEmpty ? nil : resumeData.phone,
                address: resumeData.address.isEmpty ? nil : resumeData.address,
                website: resumeData.website.isEmpty ? nil : resumeData.website
            )
            
            if success {
                let resumes = dbManager.getResumesByUserId(user.id)
                resumeId = resumes.first?.id ?? 0
                resumeData.id = resumeId
            } else {
                saveMessage = "Failed to save resume"
                showingSaveAlert = true
                return
            }
        }
        
        for education in educationEntries {
            if education.id == nil {
                _ = dbManager.insertEducation(
                    resumeId: resumeId,
                    institution: education.institution,
                    degree: education.degree.isEmpty ? nil : education.degree,
                    fieldOfStudy: education.fieldOfStudy.isEmpty ? nil : education.fieldOfStudy,
                    startDate: education.startDate.isEmpty ? nil : education.startDate,
                    endDate: education.endDate.isEmpty ? nil : education.endDate,
                    description: education.description.isEmpty ? nil : education.description
                )
            }
        }
        
        for experience in experienceEntries {
            if experience.id == nil {
                _ = dbManager.insertExperience(
                    resumeId: resumeId,
                    company: experience.company,
                    position: experience.position,
                    startDate: experience.startDate.isEmpty ? nil : experience.startDate,
                    endDate: experience.endDate.isEmpty ? nil : experience.endDate,
                    description: experience.description.isEmpty ? nil : experience.description,
                    location: experience.location.isEmpty ? nil : experience.location
                )
            }
        }
        
        saveMessage = "Resume saved successfully!"
        showingSaveAlert = true
        isEditing = false
        saveOriginalData()
    }
}

#Preview {
    HomeView()
        .environmentObject(AuthManager())
}
