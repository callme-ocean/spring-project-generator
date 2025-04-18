package in.oceanbytes.spring_project_generator.utils;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.nio.file.DirectoryNotEmptyException;
import java.nio.file.Files;
import java.nio.file.NoSuchFileException;
import java.nio.file.Path;
import java.util.Comparator;
import java.util.stream.Stream;
import java.util.zip.ZipEntry;
import java.util.zip.ZipOutputStream;

public final class FileUtils {

    private static final Logger LOGGER = LoggerFactory.getLogger(FileUtils.class);

    private FileUtils() {
    }

    public static void zipDirectory(File sourceDir, File zipFile) throws IOException {
        try (FileOutputStream fos = new FileOutputStream(zipFile);
             ZipOutputStream zos = new ZipOutputStream(fos)) {
            zipFileRecursively(sourceDir, sourceDir.getName(), zos);
        }
    }

    private static void zipFileRecursively(File fileToZip, String fileName, ZipOutputStream zos) throws IOException {
        if (fileToZip.isHidden()) {
            return;
        }
        if (fileToZip.isDirectory()) {
            if (!fileName.endsWith("/")) {
                fileName += "/";
            }
            zos.putNextEntry(new ZipEntry(fileName));
            zos.closeEntry();
            File[] children = fileToZip.listFiles();
            if (children != null) {
                for (File childFile : children) {
                    zipFileRecursively(childFile, fileName + childFile.getName(), zos);
                }
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

    public static void cleanWorkingDirectory(File workingDir, File exceptionFile) {
        File[] files = workingDir.listFiles();
        if (files != null) {
            for (File file : files) {
                if (!file.getAbsolutePath().equals(exceptionFile.getAbsolutePath())) {
                    deleteRecursively(file);
                }
            }
        }
    }

    /**
     * Recursively deletes a file or directory.
     */
    public static void deleteRecursively(File file) {
        Path path = file.toPath();
        try {
            if (Files.isDirectory(path)) {
                File[] children = file.listFiles();
                if (children != null) {
                    for (File child : children) {
                        deleteRecursively(child);
                    }
                }
            }
            Files.delete(path);
            LOGGER.debug("Deleted: {}", path);
        } catch (NoSuchFileException e) {
            LOGGER.error("File does not exist: {}", path, e);
        } catch (DirectoryNotEmptyException e) {
            LOGGER.error("Directory not empty: {}", path, e);
        } catch (IOException e) {
            LOGGER.error("Failed to delete: {} - {}", path, e.getMessage(), e);
        }
    }

    /**
     * Deletes all regular files under the directory.
     */
    public static void deleteFilesInDirectory(Path directory) {
        try (Stream<Path> pathStream = Files.walk(directory)) {
            pathStream.filter(Files::isRegularFile)
                    .sorted(Comparator.reverseOrder())
                    .forEach(path -> {
                        try {
                            Files.deleteIfExists(path);
                            LOGGER.info("Deleted file on shutdown: {}", path);
                        } catch (IOException e) {
                            LOGGER.error("Failed to delete file: {}", path, e);
                        }
                    });
        } catch (IOException e) {
            LOGGER.error("Failed to walk directory: {}", directory, e);
        }
    }
}
