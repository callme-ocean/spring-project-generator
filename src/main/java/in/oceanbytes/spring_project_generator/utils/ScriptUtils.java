package in.oceanbytes.spring_project_generator.utils;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.*;

public final class ScriptUtils {

    private static final Logger LOGGER = LoggerFactory.getLogger(ScriptUtils.class);

    private ScriptUtils() {
    }

    /**
     * Extracts all required shell scripts from the classpath (resources/scripts/) to the specified directory.
     * The scripts array should contain the names of the scripts to extract.
     */
    public static void extractScriptsToTempDir(File workingDir, String[] scripts) throws IOException {
        for (String scriptName : scripts) {
            InputStream scriptStream = ScriptUtils.class.getResourceAsStream("/scripts/" + scriptName);
            if (scriptStream == null) {
                throw new FileNotFoundException("Script file not found in resources: /scripts/" + scriptName);
            }
            File outFile = new File(workingDir, scriptName);
            try (FileOutputStream out = new FileOutputStream(outFile)) {
                byte[] buffer = new byte[1024];
                int bytesRead;
                while ((bytesRead = scriptStream.read(buffer)) != -1) {
                    out.write(buffer, 0, bytesRead);
                }
            }
            // Mark the file as executable (works on Unix-like systems)
            if (!outFile.setExecutable(true)) {
                LOGGER.error("Warning: Could not mark {} as executable", scriptName);
            }
        }
    }
}
