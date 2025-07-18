# Implementation Plan

- [x] 1. Set up environment variables for Vault OIDC
  - Create environment variable definitions for Vault OIDC configuration
  - Update documentation to reflect new environment variables
  - _Requirements: 2.1_

- [x] 2. Update OAuth configuration module
  - [x] 2.1 Refactor oauth.py to support Vault OIDC provider
    - Modify OAuth client registration to use Vault OIDC endpoints
    - Update provider configuration with Vault OIDC parameters
    - _Requirements: 2.2, 2.3_
  
  - [x] 2.2 Implement token handling for Vault OIDC
    - Update token exchange and validation logic
    - Extract user information from Vault tokens
    - _Requirements:2.3, 2.4_
  
  - [x] 2.3 Update login route handler
    - Modify login route to redirect to Vault authorization endpoint
    - Handle authorization code exchange with Vault token endpoint
    - _Requirements: 1.1, 1.2_
  
  - [x] 2.4 Update logout functionality
    - Implement proper session termination
    - Redirect to Vault logout endpoint if required
    - _Requirements: 1.4, 4.4_

- [x] 3. Update authentication middleware
  - [x] 3.1 Modify token validation for Vault tokens
    - Update check_auth function to validate Vault tokens
    - Ensure proper extraction of username from Vault tokens
    - _Requirements: 1.3, 4.1, 4.2_
  
  - [x] 3.2 Implement error handling for authentication failures
    - Add proper error messages for authentication failures
    - Ensure security by not exposing sensitive information
    - _Requirements: 3.4, 4.3_

- [x] 4. Update user interface components
  - [x] 4.1 Update login flow UI elements
    - Ensure UI elements are consistent with Vault authentication
    - Maintain the same user experience flow
    - _Requirements: 3.1_
  
  - [x] 4.2 Update error message display
    - Implement clear error messages for authentication issues
    - Ensure messages are user-friendly
    - _Requirements: 3.4, 4.3_

- [x] 5. Implement token management
  - [x] 5.1 Add token refresh mechanism
    - Implement token refresh when tokens are about to expire
    - Handle refresh failures gracefully
    - _Requirements: 1.3, 2.4_
  
  - [x]5.2Ensure secure token storage
    - Review session storage security
    - Implement proper token invalidation on logout
    - _Requirements: 4.1, 4.4_

- [x] 6. Update API communication
  - Update API request handling to use Vault tokens
  - Ensure backward compatibility with existing API endpoints
  - _Requirements: 3.3_

- [x] 7. Update Terraform configuration
  - [x] 7.1 Remove Cognito user pool creation
    - Update main.tf to remove Cognito module reference
    - Create a new module for Vault OIDC configuration
    - _Requirements: 2.1,2.2_
  
  - [x] 7.2 Update agent-authorizer to work with Vault OIDC
    - Modify agent-authorizer to use Vault JWKS URL
    - Update environment variables in Terraform
    - _Requirements: 2.3, 3.3_