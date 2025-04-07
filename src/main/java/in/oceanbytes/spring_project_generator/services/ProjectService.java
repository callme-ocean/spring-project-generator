package in.oceanbytes.spring_project_generator.services;

import in.oceanbytes.spring_project_generator.models.ProjectRequest;
import org.springframework.stereotype.Service;

import java.io.*;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.zip.ZipEntry;
import java.util.zip.ZipOutputStream;

@Service
public class ProjectService {

    public File generateProject(ProjectRequest request) throws Exception {
        // Base directory where the final zip file will reside.
        Path baseDir = Paths.get("target", "generated-projects");
        Files.createDirectories(baseDir);

        String projectName = request.getProjectName();
        String groupName = request.getGroupName();
        String packageCsv = String.join(",", request.getPackages());

        // Prepare the APIs parameter (if any)
        String apis = "";
        if (request.getApis() != null && !request.getApis().isEmpty()) {
            apis = String.join(",", request.getApis());
        }

        // Create a temporary working directory under baseDir for project generation.
        Path tempDir = Files.createTempDirectory(baseDir, "project_");

        // Extract all required scripts from resources to tempDir.
        extractScriptsToTempDir(tempDir);

        // Determine the main script file (assumed to be main.sh)
        File mainScriptFile = new File(tempDir.toFile(), "main.sh");
        if (!mainScriptFile.exists()) {
            throw new FileNotFoundException("Main script not found in temporary directory.");
        }

        // Prepare the command based on the operating system.
        String osName = System.getProperty("os.name").toLowerCase();
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
                System.err.println(line);
            }
        }

        int exitCode = process.waitFor();
        if (exitCode != 0) {
            throw new RuntimeException("Script execution failed with exit code " + exitCode);
        }

        // The script creates the project directory under tempDir.
        File projectDir = new File(tempDir.toFile(), projectName);
        if (!projectDir.exists()) {
            throw new RuntimeException("Project directory not found after script execution.");
        }

        // Create the zip file in tempDir.
        String zipFileName = projectName + ".zip";
        File zipFileTemp = new File(tempDir.toFile(), zipFileName);
        zipDirectory(projectDir, zipFileTemp);

        // Clean up: delete everything inside tempDir except the zip file.
        cleanWorkingDirectory(tempDir.toFile(), zipFileTemp);

        // Move the zip file to baseDir (target/generated-projects) and overwrite if it exists.
        Path targetZipPath = baseDir.resolve(zipFileName);
        Files.move(zipFileTemp.toPath(), targetZipPath, java.nio.file.StandardCopyOption.REPLACE_EXISTING);

        // Delete the temporary directory.
        deleteRecursively(tempDir.toFile());

        return targetZipPath.toFile();
    }

    /**
     * Extracts all required shell scripts from the classpath (resources/scripts/) to the specified directory.
     * This includes main.sh, create_directories.sh, generate_configs.sh, and generate_sources.sh.
     */
    private void extractScriptsToTempDir(Path workingDir) throws IOException {
        String[] scripts = {"main.sh", "create_directories.sh", "generate_configs.sh", "generate_classes.sh"};
        for (String scriptName : scripts) {
            InputStream scriptStream = getClass().getResourceAsStream("/scripts/" + scriptName);
            if (scriptStream == null) {
                throw new FileNotFoundException("Script file not found in resources: /scripts/" + scriptName);
            }
            File outFile = new File(workingDir.toFile(), scriptName);
            try (FileOutputStream out = new FileOutputStream(outFile)) {
                byte[] buffer = new byte[1024];
                int bytesRead;
                while ((bytesRead = scriptStream.read(buffer)) != -1) {
                    out.write(buffer, 0, bytesRead);
                }
            }
            // Mark the file as executable (works on Unix-like systems)
            if (!outFile.setExecutable(true)) {
                System.err.println("Warning: Could not mark " + scriptName + " as executable");
            }
        }
    }

    private void zipDirectory(File sourceDir, File zipFile) throws IOException {
        try (FileOutputStream fos = new FileOutputStream(zipFile);
             ZipOutputStream zos = new ZipOutputStream(fos)) {
            zipFileRecursively(sourceDir, sourceDir.getName(), zos);
        }
    }

    private void zipFileRecursively(File fileToZip, String fileName, ZipOutputStream zos) throws IOException {
        if (fileToZip.isHidden()) {
            return;
        }
        if (fileToZip.isDirectory()) {
            if (!fileName.endsWith("/")) {
                fileName += "/";
            }
            zos.putNextEntry(new ZipEntry(fileName));
            zos.closeEntry();
            for (File childFile : fileToZip.listFiles()) {
                zipFileRecursively(childFile, fileName + childFile.getName(), zos);
            }
            return;
        }
        try (FileInputStream fis = new FileInputStream(fileToZip)) {
            ZipEntry zipEntry = new ZipEntry(fileName);
            zos.putNextEntry(zipEntry);
            byte[] bytes = new byte[1024];
            int length;
            while ((length = fis.read(bytes)) >= 0) {
                zos.write(bytes, 0, length);
            }
        }
    }

    /**
     * Cleans the working directory by deleting all files and folders except the zip file.
     */
    private void cleanWorkingDirectory(File workingDir, File zipFile) {
        File[] files = workingDir.listFiles();
        if (files != null) {
            for (File file : files) {
                if (!file.getAbsolutePath().equals(zipFile.getAbsolutePath())) {
                    deleteRecursively(file);
                }
            }
        }
    }

    /**
     * Recursively deletes a file or directory.
     */
    private void deleteRecursively(File file) {
        if (file.isDirectory()) {
            File[] children = file.listFiles();
            if (children != null) {
                for (File child : children) {
                    deleteRecursively(child);
                }
            }
        }
        if (!file.delete()) {
            System.err.println("Failed to delete: " + file.getAbsolutePath());
        }
    }
}
