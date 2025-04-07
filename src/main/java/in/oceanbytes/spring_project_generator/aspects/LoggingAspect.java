package in.oceanbytes.spring_project_generator.aspects;

import jakarta.servlet.http.HttpServletRequest;
import org.aspectj.lang.JoinPoint;
import org.aspectj.lang.ProceedingJoinPoint;
import org.aspectj.lang.annotation.*;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Component;
import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;

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

    @Around("execution(* in.oceanbytes.spring_project_generator.services.*.*(..))")
    public Object logAround(ProceedingJoinPoint proceedingJoinPoint) throws Throwable {
        LOGGER.info("Entering method: {}", proceedingJoinPoint.getSignature());
        Object result = proceedingJoinPoint.proceed();
        LOGGER.info("Exiting method: {}", proceedingJoinPoint.getSignature());
        return result;
    }
}
