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

# If the user selected the "aspects" package, generate LoggingAspect.java.
if echo "$PACKAGES_CSV" | grep -iw "aspects" > /dev/null; then
    # Create the aspects directory if it doesn't exist
    mkdir -p "$BASE_DIR/aspects"
    cat <<EOF > "$BASE_DIR/aspects/LoggingAspect.java"
package ${GROUP_NAME}.${PACKAGE_NAME}.aspects;

import org.aspectj.lang.JoinPoint;
import org.aspectj.lang.ProceedingJoinPoint;
import org.aspectj.lang.annotation.*;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Component;
import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;

import jakarta.servlet.http.HttpServletRequest;
import java.lang.invoke.MethodHandles;

@Aspect
@Component("webLoggingAspect")
public class LoggingAspect {
    private static final Logger LOGGER = LoggerFactory.getLogger(MethodHandles.lookup().lookupClass());

    // Pointcuts for HTTP methods
    @Pointcut("@annotation(org.springframework.web.bind.annotation.PostMapping)")
    public void allPostMappings() {}

    @Pointcut("@annotation(org.springframework.web.bind.annotation.PutMapping)")
    public void allPutMappings() {}

    @Pointcut("@annotation(org.springframework.web.bind.annotation.GetMapping)")
    public void allGetMappings() {}

    @Pointcut("@annotation(org.springframework.web.bind.annotation.DeleteMapping)")
    public void allDeleteMappings() {}

    // Combined pointcut
    @Pointcut("allPostMappings() || allPutMappings() || allGetMappings() || allDeleteMappings()")
    public void restEndpoints() {}

    @Before("restEndpoints()")
    public void logBeforeRestCall(JoinPoint joinPoint) {
        HttpServletRequest httpServletRequest = ((ServletRequestAttributes) RequestContextHolder.currentRequestAttributes()).getRequest();
        LOGGER.info("Request Received [{}]", httpServletRequest.getRequestURI());
    }

    @AfterReturning(value = "restEndpoints()", returning = "responseObj")
    public Object logAfterSuccessfulRestCall(Object responseObj) {
        HttpServletRequest httpServletRequest = ((ServletRequestAttributes) RequestContextHolder.currentRequestAttributes()).getRequest();
        LOGGER.info("Request Serviced Successful [{}]", httpServletRequest.getRequestURI());
        return responseObj;
    }

    @AfterThrowing(value = "restEndpoints()", throwing = "exception")
    public void logAfterFailedRestResponse(Throwable exception) {
        HttpServletRequest httpServletRequest = ((ServletRequestAttributes) RequestContextHolder.currentRequestAttributes()).getRequest();
        LOGGER.error("{} : {}", exception.getClass().getSimpleName(), exception.getMessage());
        LOGGER.info("Request Serviced [{}]", httpServletRequest.getRequestURI());
    }

    @Around("execution(* ${GROUP_NAME}.${PACKAGE_NAME}.services.*.*(..))")
    public Object logAround(ProceedingJoinPoint proceedingJoinPoint) throws Throwable {
        LOGGER.info("Entering method: {}", proceedingJoinPoint.getSignature());
        Object result = proceedingJoinPoint.proceed();
        LOGGER.info("Exiting method: {}", proceedingJoinPoint.getSignature());
        return result;
    }
}
EOF
fi

# If the user selected the "constants" package, generate ApplicationConstants.java.
if echo "$PACKAGES_CSV" | grep -iw "constants" > /dev/null; then
    mkdir -p "$BASE_DIR/constants"
    cat <<EOF > "$BASE_DIR/constants/ApplicationConstants.java"
package ${GROUP_NAME}.${PACKAGE_NAME}.constants;

public final class ApplicationConstants {

    private ApplicationConstants() {
    }

    public static final String APPLICATION_NAME = "MySpringBootApp";
}
EOF
fi

