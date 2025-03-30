package in.oceanbytes.spring_project_generator.models;

import java.util.List;

public class ProjectRequest {
    private String projectName;
    private List<String> packages;

    // Getters and setters

    public String getProjectName() {
        return projectName;
    }
    public void setProjectName(String projectName) {
        this.projectName = projectName;
    }
    public List<String> getPackages() {
        return packages;
    }
    public void setPackages(List<String> packages) {
        this.packages = packages;
    }
}