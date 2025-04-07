package in.oceanbytes.spring_project_generator.controllers;

import in.oceanbytes.spring_project_generator.models.ProjectRequest;
import in.oceanbytes.spring_project_generator.services.ProjectService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.InputStreamResource;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

import java.io.File;
import java.io.FileInputStream;
import java.util.Arrays;
import java.util.List;

@Controller
@RequestMapping("/v2")
public class HomeController {

    private static final Logger LOGGER = LoggerFactory.getLogger(HomeController.class);

    private final ProjectService projectService;

    @Value("${project.generator.available-packages}")
    private String availablePackagesRaw;

    @Value("${project.generator.available-apis}")
    private String availableApisRaw;

    public HomeController(ProjectService projectService) {
        this.projectService = projectService;
    }


    // Display the UI form.
    @GetMapping("/generator")
    public String showForm(Model model) {
        // Define the list of packages that users can select.
        List<String> availablePackages = Arrays.asList(availablePackagesRaw.split(","));
        LOGGER.debug("availablePackages : {}", availablePackages);

        // Define the list of APIs.
        List<String> availableAPIs = Arrays.asList(availableApisRaw.split(","));
        LOGGER.debug("availableAPIs : {}", availableAPIs);

        model.addAttribute("availablePackages", availablePackages);
        model.addAttribute("availableAPIs", availableAPIs);
        // Bind an empty ProjectRequest for form data binding.
        model.addAttribute("projectRequest", new ProjectRequest());

        return "index"; // Returns the index.html template.
    }

    // Handle the form submission and return the generated zip file.
    @GetMapping(value = "/generate", produces = "application/zip")
    public ResponseEntity<InputStreamResource> generateProject(ProjectRequest projectRequest) throws Exception {
        File zipFile = projectService.generateProject(projectRequest);
        InputStreamResource resource = new InputStreamResource(new FileInputStream(zipFile));

        return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=\"" + zipFile.getName() + "\"")
                .contentLength(zipFile.length())
                .contentType(MediaType.valueOf("application/zip"))
                .body(resource);
    }
}
