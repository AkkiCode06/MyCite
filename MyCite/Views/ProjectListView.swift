//
//  ProjectListView.swift
//  MyCite
//
//  Created by Akshat Barjatya on 23/02/2026.
//

import SwiftUI
import SwiftData

struct ProjectListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Project.createdDate, order: .reverse) private var projects: [Project]
    @Binding var selectedProject: Project?

    @State private var isAddingProject = false
    @State private var newProjectName = ""
    @State private var renamingProject: Project?
    @State private var renameText = ""

    var body: some View {
        List(selection: $selectedProject) {
            ForEach(projects) { project in
                projectRow(project)
                    .tag(project)
                    .contextMenu {
                        Button("Rename") {
                            renamingProject = project
                            renameText = project.name
                        }
                        Divider()
                        Button("Delete", role: .destructive) {
                            deleteProject(project)
                        }
                    }
            }
        }
        .listStyle(.sidebar)
        .navigationTitle("Projects")
        .toolbar {
            ToolbarItem {
                Button(action: { isAddingProject = true }) {
                    Label("New Project", systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $isAddingProject) {
            addProjectSheet
        }
        .sheet(item: $renamingProject) { project in
            renameProjectSheet(project)
        }
    }

    // MARK: - Project Row

    @ViewBuilder
    private func projectRow(_ project: Project) -> some View {
        HStack {
            Image(systemName: "folder.fill")
                .foregroundStyle(.blue)
            VStack(alignment: .leading, spacing: 2) {
                Text(project.name)
                    .font(.headline)
                Text("\(project.sources.count) source\(project.sources.count == 1 ? "" : "s")")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }

    // MARK: - Add Project Sheet

    private var addProjectSheet: some View {
        VStack(spacing: 16) {
            Text("New Project")
                .font(.title2.bold())

            TextField("Project name", text: $newProjectName)
                .textFieldStyle(.roundedBorder)
                .frame(width: 260)
                .onSubmit { addProject() }

            HStack {
                Button("Cancel") {
                    newProjectName = ""
                    isAddingProject = false
                }
                .keyboardShortcut(.cancelAction)

                Button("Create") { addProject() }
                    .keyboardShortcut(.defaultAction)
                    .disabled(newProjectName.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
        .padding(24)
    }

    // MARK: - Rename Project Sheet

    private func renameProjectSheet(_ project: Project) -> some View {
        VStack(spacing: 16) {
            Text("Rename Project")
                .font(.title2.bold())

            TextField("Project name", text: $renameText)
                .textFieldStyle(.roundedBorder)
                .frame(width: 260)
                .onSubmit { renameProject(project) }

            HStack {
                Button("Cancel") {
                    renamingProject = nil
                }
                .keyboardShortcut(.cancelAction)

                Button("Rename") { renameProject(project) }
                    .keyboardShortcut(.defaultAction)
                    .disabled(renameText.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
        .padding(24)
    }

    // MARK: - Actions

    private func addProject() {
        let name = newProjectName.trimmingCharacters(in: .whitespaces)
        guard !name.isEmpty else { return }
        let project = Project(name: name)
        modelContext.insert(project)
        newProjectName = ""
        isAddingProject = false
        selectedProject = project
    }

    private func renameProject(_ project: Project) {
        let name = renameText.trimmingCharacters(in: .whitespaces)
        guard !name.isEmpty else { return }
        project.name = name
        renamingProject = nil
    }

    private func deleteProject(_ project: Project) {
        if selectedProject == project {
            selectedProject = nil
        }
        modelContext.delete(project)
    }
}
