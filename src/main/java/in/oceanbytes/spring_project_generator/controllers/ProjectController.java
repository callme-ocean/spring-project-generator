package in.oceanbytes.spring_project_generator.controllers;

import in.oceanbytes.spring_project_generator.models.ProjectRequest;
import in.oceanbytes.spring_project_generator.services.ProjectService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.io.InputStreamResource;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.io.File;
import java.io.FileInputStream;

@RestController
@RequestMapping("/v1")
public class ProjectController {

    @Autowired
    private ProjectService projectService;

    @PostMapping("/generate")
    public ResponseEntity<InputStreamResource> generateProject(@RequestBody ProjectRequest request) {
        try {
            File zipFile = projectService.generateProject(request);
            InputStreamResource resource = new InputStreamResource(new FileInputStream(zipFile));

            return ResponseEntity.ok()
                    .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=" + zipFile.getName())
                    .contentLength(zipFile.length())
                    .contentType(MediaType.APPLICATION_OCTET_STREAM)
                    .body(resource);
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.internalServerError().build();
        }
    }
}
