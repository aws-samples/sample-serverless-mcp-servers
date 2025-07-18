# Change Plan for Updating strands-agent-on-lambda-vault

## Overview
This document outlines the plan to update the `strands-agent-on-lambda-vault` project by incorporating the recent changes from the upstream repository that were made to `strands-agent-on-lambda`. The primary change is migrating from the current state management approach to using S3SessionManager.

## Files to Change

### 1. `strands-agent-on-lambda-vault/lambdas/travel-agent/agent.py`
**Changes needed:**
- Update the agent implementation to use S3SessionManager instead of the current state management approach
- Modify how agent state is stored and retrieved
- Update any related imports and function calls

**Reason:**
The upstream repository has moved to a more scalable and reliable state management solution using S3, which provides better persistence and availability compared to the previous approach.

### 2. `strands-agent-on-lambda-vault/lambdas/travel-agent/agent_config.py` (renamed from agent_builder.py)
**Changes needed:**
- Rename the file from `agent_builder.py` to `agent_config.py`
- Update the implementation to align with the new S3-based state management
- Modify configuration parameters to support S3 state storage

**Reason:**
The file has been renamed and refactored in the upstream repository to better reflect its purpose as a configuration provider rather than just a builder.

### 3. `strands-agent-on-lambda-vault/lambdas/travel-agent/agent_state_manager.py`
**Changes needed:**
- Remove this file completely

**Reason:**
This file is no longer needed as the state management functionality has been replaced by the S3SessionManager.

### 4. `strands-agent-on-lambda-vault/lambdas/travel-agent/app.py`
**Changes needed:**
- Update the Lambda handler to work with the new S3SessionManager
- Modify any state initialization or retrieval logic

**Reason:**
The application entry point needs to be updated to use the new state management approach.

### 5. `strands-agent-on-lambda-vault/lambdas/travel-agent/requirements.txt`
**Changes needed:**
- Add this new file with the required dependencies for the travel agent Lambda

**Reason:**
A dedicated requirements file helps ensure all necessary dependencies are properly installed in the Lambda environment.

### 6. `strands-agent-on-lambda-vault/layers/dependencies/requirements.txt`
**Changes needed:**
- Update dependencies to include any new packages needed for S3SessionManager

**Reason:**
The Lambda layer needs to include all dependencies required by the updated code.

### 7. `strands-agent-on-lambda-vault/terraform/modules/agent-dependencies/requirements.txt`
**Changes needed:**
- Update dependencies to match the changes in the Lambda layer requirements

**Reason:**
Ensures consistency between the Lambda layer and the Terraform module that builds it.

### 8. `strands-agent-on-lambda-vault/terraform/modules/agent/iam.tf`
**Changes needed:**
- Add S3 permissions to allow the Lambda function to access S3 buckets for state management
- Update existing IAM policies as needed

**Reason:**
The Lambda function now needs permissions to read from and write to S3 buckets for state management.

### 9. `strands-agent-on-lambda-vault/terraform/modules/agent/main.tf`
**Changes needed:**
- Add S3 bucket resource for state management
- Update Lambda function configuration to include S3 environment variables
- Modify any other Terraform resources to support the new architecture

**Reason:**
The infrastructure needs to be updated to support the S3-based state management approach.

### 10. `strands-agent-on-lambda-vault/img/arch.png`
**Changes needed:**
- Replace with the updated architecture diagram

**Reason:**
The architecture diagram should reflect the new design with S3SessionManager.

### 11. `strands-agent-on-lambda-vault/README.md`
**Changes needed:**
- Update documentation to reflect the new S3-based state management approach
- Update any instructions or examples

**Reason:**
Documentation should accurately reflect the current implementation.

## Files to Ignore
- Any files in the `lib/` directory
- Any CDK-related files or changes, as we are not using CDK

## Implementation Strategy
1. Start by updating the Terraform infrastructure files to add the necessary S3 resources and permissions
2. Update the Lambda code to use the S3SessionManager
3. Update the requirements files to include any new dependencies
4. Update the documentation and architecture diagram
5. Test the changes to ensure everything works correctly
6. Commit the changes with a clear message explaining the migration to S3SessionManager

## Testing Plan
1. Deploy the updated infrastructure using Terraform
2. Test the Lambda function to ensure it can store and retrieve state from S3
3. Test the entire workflow to ensure all components work together correctly
4. Verify that the Vault authentication still works properly with the new state management approach

This plan provides a comprehensive approach to updating the `strands-agent-on-lambda-vault` project to use the S3SessionManager, aligning it with the changes made in the upstream repository.
