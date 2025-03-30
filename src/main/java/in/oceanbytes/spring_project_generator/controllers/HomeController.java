package in.oceanbytes.spring_project_generator.controllers;

import in.oceanbytes.spring_project_generator.models.ProjectRequest;
import in.oceanbytes.spring_project_generator.services.ProjectService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.io.InputStreamResource;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;

import java.io.File;
import java.io.FileInputStream;

@Controller
@RequestMapping("/v2")
public class HomeController {

    @Autowired
    private ProjectService projectService;

    // Display the UI form.
    @GetMapping("/generator")
    public String showForm(Model model) {
        System.out.printf("inside");
        // Define the list of packages that users can select.
        String[] availablePackages = {
                "controllers", "services", "repositories", "models",
                "exceptions", "config", "common", "constants", "aspects", "entities"
        };
        model.addAttribute("availablePackages", availablePackages);
        // Bind an empty ProjectRequest for form data binding.
        model.addAttribute("projectRequest", new ProjectRequest());
        return "index"; // Returns the index.html template.
    }

    // Handle the form submission and return the generated zip file.
    @PostMapping("/generate")
    public ResponseEntity<InputStreamResource> generateProject(ProjectRequest projectRequest) throws Exception {
        File zipFile = projectService.generateProject(projectRequest);
        InputStreamResource resource = new InputStreamResource(new FileInputStream(zipFile));

        return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=" + zipFile.getName())
                .contentLength(zipFile.length())
                .contentType(MediaType.APPLICATION_OCTET_STREAM)
                .body(resource);
    }
}
