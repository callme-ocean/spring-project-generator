package in.oceanbytes.spring_project_generator.controllers;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class RootRedirectController {

    @GetMapping("/")
    public String redirectToGenerator() {
        return "redirect:/api/spring-project-generator/v1/generator";
    }
}

