package in.oceanbytes.spring_project_generator.services;

import in.oceanbytes.spring_project_generator.exceptions.ServiceException;
import in.oceanbytes.spring_project_generator.models.ProjectRequest;
import in.oceanbytes.spring_project_generator.utils.FileUtils;
import in.oceanbytes.spring_project_generator.utils.ScriptUtils;
import jakarta.annotation.PreDestroy;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import java.io.*;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;

@Service
public class ProjectService {

    private static final Logger LOGGER = LoggerFactory.getLogger(ProjectService.class);


    // Common directory for generated projects.
    private static final Path GENERATED_PROJECTS_DIR = Paths.get("target", "generated-projects");

    // Scheduler to delete generated files after 60 seconds.
    private static final ScheduledExecutorService scheduler = Executors.newScheduledThreadPool(1);

    public File generateProject(ProjectRequest request) throws Exception {
        // Create the base directory if it doesn't exist.
        Files.createDirectories(GENERATED_PROJECTS_DIR);

        String projectName = request.getProjectName();
        String groupName = request.getGroupName();
        String packageCsv = String.join(",", request.getPackages());

        // Prepare the APIs parameter (if any)
        String apis = "";
        if (request.getApis() != null && !request.getApis().isEmpty()) {
            apis = String.join(",", request.getApis());
        }

        // Create a temporary working directory under GENERATED_PROJECTS_DIR for project generation.
        Path tempDir = Files.createTempDirectory(GENERATED_PROJECTS_DIR, "project_");
        LOGGER.debug("tempDir path : {}", tempDir);

        // Extract all required scripts from resources to tempDir.
        String[] scripts = {"main.sh", "create_directories.sh", "generate_configs.sh", "generate_classes.sh"};
        ScriptUtils.extractScriptsToTempDir(tempDir.toFile(), scripts);

        // Determine the main script file (assumed to be main.sh)
        File mainScriptFile = new File(tempDir.toFile(), "main.sh");
        if (!mainScriptFile.exists()) {
            throw new FileNotFoundException("Main script not found in temporary directory.");
        }

        // Prepare the command based on the operating system.
        String osName = System.getProperty("os.name").toLowerCase();
        LOGGER.debug("osName : {}", osName);

        ProcessBuilder pb;
        if (osName.contains("win")) {
            // On Windows, run via bash (ensure bash is in PATH)
            if (apis.isEmpty()) {
                pb = new ProcessBuilder("bash", mainScriptFile.getAbsolutePath(), projectName, groupName, packageCsv);
            } else {
                pb = new ProcessBuilder("bash", mainScriptFile.getAbsolutePath(), projectName, groupName, packageCsv, apis);
            }
        } else {
            if (apis.isEmpty()) {
                pb = new ProcessBuilder(mainScriptFile.getAbsolutePath(), projectName, groupName, packageCsv);
            } else {
                pb = new ProcessBuilder(mainScriptFile.getAbsolutePath(), projectName, groupName, packageCsv, apis);
            }
        }
        pb.directory(tempDir.toFile());
        Process process = pb.start();

        // Log error output if any.
        try (BufferedReader errorReader = new BufferedReader(new InputStreamReader(process.getErrorStream()))) {
            String line;
            while ((line = errorReader.readLine()) != null) {
                LOGGER.error(line);
            }
        }

        int exitCode = process.waitFor();
        if (exitCode != 0) {
            throw new ServiceException("Script execution failed with exit code " + exitCode);
        }

        // The script creates the project directory under tempDir.
        File projectDir = new File(tempDir.toFile(), projectName);
        if (!projectDir.exists()) {
            throw new ServiceException("Project directory not found after script execution.");
        }

        // Create the zip file in tempDir.
        String zipFileName = projectName + ".zip";
        File zipFileTemp = new File(tempDir.toFile(), zipFileName);
        FileUtils.zipDirectory(projectDir, zipFileTemp);

        // Clean up: delete everything inside tempDir except the zip file.
        FileUtils.cleanWorkingDirectory(tempDir.toFile(), zipFileTemp);

        // Move the zip file to GENERATED_PROJECTS_DIR (overwriting if it exists).
        Path targetZipPath = GENERATED_PROJECTS_DIR.resolve(zipFileName);
        Files.move(zipFileTemp.toPath(), targetZipPath, StandardCopyOption.REPLACE_EXISTING);

        // Delete the temporary directory.
        FileUtils.deleteRecursively(tempDir.toFile());

        // Schedule deletion of the generated zip file after 60 seconds.
        scheduler.schedule(() -> {
            try {
                Files.deleteIfExists(targetZipPath);
                LOGGER.info("Scheduled deletion: Deleted file {}", targetZipPath);
            } catch (IOException e) {
                LOGGER.error(e.getMessage());
            }
        }, 60, TimeUnit.SECONDS);

        return targetZipPath.toFile();
    }

    /**
     * Deletes all regular files under the GENERATED_PROJECTS_DIR when the application is stopping.
     */
    @PreDestroy
    public void cleanupOnShutdown() {
        LOGGER.info("Cleaning up generated projects on shutdown...");
        FileUtils.deleteFilesInDirectory(GENERATED_PROJECTS_DIR);
        scheduler.shutdown();
    }
}
