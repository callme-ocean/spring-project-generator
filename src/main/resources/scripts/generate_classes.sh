#!/bin/bash
set -euo pipefail

# Create the main application class
cat > "$BASE_DIR/${APP_CLASS_NAME}.java" <<EOF
package ${GROUP_NAME}.${PACKAGE_NAME};

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class ${APP_CLASS_NAME} {
    public static void main(String[] args) {
        SpringApplication.run(${APP_CLASS_NAME}.class, args);
    }
}
EOF

# If "controllers" is among the provided packages, generate ExampleController.java with API methods if provided.
if echo "$PACKAGES_CSV" | grep -iwq "controllers"; then
  API_METHODS=""
  APIS=$(echo "$APIS" | xargs)
  if [[ -n "$APIS" ]]; then
    IFS=',' read -ra API_ARRAY <<< "$APIS"
    for api in "${API_ARRAY[@]}"; do
      api_upper=$(tr '[:lower:]' '[:upper:]' <<< "$api")
      case "$api_upper" in
        GET)
          API_METHODS+=$'\n'"    @GetMapping
    public ResponseEntity<List<String>> getAllItems() {
        return ResponseEntity.ok(new ArrayList<>(items.values()));
    }

    @GetMapping(\"/{id}\")
    public ResponseEntity<String> getItemById(@PathVariable Long id) {
        String item = items.get(id);
        return item != null ? ResponseEntity.ok(item) : ResponseEntity.notFound().build();
    }"
          ;;
        POST)
          API_METHODS+=$'\n'"    @PostMapping
    public ResponseEntity<String> createItem(@RequestBody String item) {
        long id = idCounter++;
        items.put(id, item);
        return ResponseEntity.status(HttpStatus.CREATED).body(\"Item created with ID: \" + id);
    }"
          ;;
        PUT)
          API_METHODS+=$'\n'"    @PutMapping(\"/{id}\")
    public ResponseEntity<String> updateItem(@PathVariable Long id, @RequestBody String newItem) {
        if (!items.containsKey(id)) {
            return ResponseEntity.notFound().build();
        }
        items.put(id, newItem);
        return ResponseEntity.ok(\"Item updated successfully\");
    }"
          ;;
        DELETE)
          API_METHODS+=$'\n'"    @DeleteMapping(\"/{id}\")
    public ResponseEntity<String> deleteItem(@PathVariable Long id) {
        if (!items.containsKey(id)) {
            return ResponseEntity.notFound().build();
        }
        items.remove(id);
        return ResponseEntity.ok(\"Item deleted successfully\");
    }"
          ;;
        *)
          # Skip unknown API types.
          ;;
      esac
    done
  fi

  mkdir -p "$BASE_DIR/controllers"
  cat > "$BASE_DIR/controllers/ExampleController.java" <<EOF
package ${GROUP_NAME}.${PACKAGE_NAME}.controllers;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

@RestController
@RequestMapping("/v1")
public class ExampleController {

    private Map<Long, String> items = new ConcurrentHashMap<>();
    private long idCounter = 1;

${API_METHODS}
}
EOF
fi
