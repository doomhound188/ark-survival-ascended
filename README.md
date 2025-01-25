
## Testing and Validation

### GitHub Actions Workflow
The project includes a GitHub Actions workflow that:
- Builds the Docker image
- Validates basic container startup
- Performs security scanning

### Local Integration Testing

#### Prerequisites
- Docker
- Bash environment

#### Running Integration Tests
```bash
chmod +x tests/integration_test.sh
./tests/integration_test.sh
```

#### Manual Verification Checklist
1. Verify Docker image builds successfully
2. Check container starts without immediate errors
3. Validate port mappings
4. Review container logs for any startup issues
5. Perform manual game server connection tests in your local environment

### Troubleshooting
- Ensure Docker is installed and running
- Check that required environment variables are set
- Verify network ports are available
- Review container logs for specific error messages

## Notes
- Ensure you have a stable internet connection for initial download and updates
- The RCON password is required for server administration
