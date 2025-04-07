package in.oceanbytes.spring_project_generator.utils;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.Comparator;
import java.util.zip.ZipEntry;
import java.util.zip.ZipOutputStream;

public final class FileUtils {

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

    /**
     * Deletes all regular files under the directory.
     */
    public static void deleteFilesInDirectory(Path directory) {
        try {
            Files.walk(directory)
                    .filter(Files::isRegularFile)
                    .sorted(Comparator.reverseOrder())
                    .forEach(path -> {
                        try {
                            Files.deleteIfExists(path);
                            System.out.println("Deleted file on shutdown: " + path);
                        } catch (IOException e) {
                            e.printStackTrace();
                        }
                    });
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}
