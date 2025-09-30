# Contributing to Elastic Integrations Standalone

Thank you for your interest in contributing! This document provides guidelines for contributing to this project.

## How to Contribute

### Reporting Issues

If you find a bug or have a suggestion:

1. Check if the issue already exists in [GitHub Issues](https://github.com/clement-fouque/elastic-integrations-standalone/issues)
2. If not, create a new issue with:
   - Clear title and description
   - Steps to reproduce (for bugs)
   - Expected vs actual behavior
   - Your environment (OS, Docker version, etc.)
   - Relevant logs or screenshots

### Suggesting Enhancements

We welcome suggestions for new features or improvements:

1. Open an issue with the "enhancement" label
2. Describe the feature and its benefits
3. Provide examples of how it would work
4. Discuss implementation ideas if you have any

### Pull Requests

We love pull requests! Here's how to submit one:

1. **Fork the repository**
   ```bash
   # Fork on GitHub, then clone your fork
   git clone https://github.com/YOUR_USERNAME/elastic-integrations-standalone.git
   cd elastic-integrations-standalone
   ```

2. **Create a branch**
   ```bash
   git checkout -b feature/your-feature-name
   # or
   git checkout -b fix/your-bug-fix
   ```

3. **Make your changes**
   - Write clear, concise code
   - Follow existing code style
   - Add comments where necessary
   - Update documentation if needed

4. **Test your changes**
   ```bash
   # Validate Docker Compose config
   docker compose config --quiet
   
   # Test the setup
   ./scripts/setup.sh
   ./scripts/test.sh
   
   # Verify shell scripts
   bash -n scripts/*.sh
   ```

5. **Commit your changes**
   ```bash
   git add .
   git commit -m "Brief description of changes"
   ```
   
   Use clear commit messages:
   - `feat: add support for MySQL integration`
   - `fix: correct port mapping for Fleet Server`
   - `docs: update quick start guide`
   - `chore: update Elasticsearch version`

6. **Push and create PR**
   ```bash
   git push origin feature/your-feature-name
   ```
   Then open a pull request on GitHub.

## Development Guidelines

### Code Style

- **Shell Scripts**: Follow bash best practices
  - Use `set -e` for error handling
  - Add comments for complex logic
  - Use meaningful variable names
  - Quote variables: `"$VAR"` not `$VAR`

- **YAML Files**: 
  - Use 2 spaces for indentation
  - Keep lines under 120 characters
  - Use meaningful service and variable names

- **Documentation**:
  - Use clear, concise language
  - Include examples where helpful
  - Keep formatting consistent
  - Update relevant docs when changing code

### Testing

Before submitting a PR, ensure:

1. **Docker Compose config is valid**
   ```bash
   docker compose config --quiet
   ```

2. **Shell scripts have valid syntax**
   ```bash
   bash -n scripts/*.sh
   ```

3. **Services start successfully**
   ```bash
   ./scripts/setup.sh
   ```

4. **Tests pass**
   ```bash
   ./scripts/test.sh
   ```

5. **Services stop cleanly**
   ```bash
   docker compose down
   ```

### Documentation

Update relevant documentation when making changes:

- **README.md**: Main documentation
- **QUICKSTART.md**: Quick start guide
- **TROUBLESHOOTING.md**: Troubleshooting information
- **examples/**: Example configurations
- **Comments**: In-code documentation

## Project Structure

```
.
├── docker-compose.yml      # Main Docker Compose configuration
├── .env                    # Environment variables
├── .gitignore             # Git ignore patterns
├── Makefile               # Convenient make targets
├── README.md              # Main documentation
├── QUICKSTART.md          # Quick start guide
├── TROUBLESHOOTING.md     # Troubleshooting guide
├── LICENSE                # MIT License
├── CONTRIBUTING.md        # This file
├── examples/              # Example integration configurations
│   ├── README.md
│   ├── system-integration.yml
│   ├── docker-integration.yml
│   ├── nginx-integration.yml
│   └── custom-logs.yml
├── sample-data/           # Sample configuration files
│   └── nginx.conf
└── scripts/               # Utility scripts
    ├── setup.sh           # Setup and start script
    ├── test.sh            # Test and verification script
    └── cleanup.sh         # Cleanup script
```

## Adding New Features

### Adding a New Integration Example

1. Create a new YAML file in `examples/`
2. Follow the format of existing examples
3. Add comments explaining each section
4. Update `examples/README.md` to list the new example
5. Test the configuration works

### Adding a New Sample Application

1. Add service to `docker-compose.yml`
2. Place configuration files in `sample-data/`
3. Ensure service connects to the `elastic` network
4. Add documentation to README.md
5. Update setup script if needed

### Adding a New Script

1. Create script in `scripts/` directory
2. Make it executable: `chmod +x scripts/new-script.sh`
3. Add comments and error handling
4. Add target to Makefile if appropriate
5. Document usage in README.md

## Code Review Process

1. A maintainer will review your PR
2. They may request changes or ask questions
3. Make requested changes and push updates
4. Once approved, the PR will be merged

## Community Guidelines

- Be respectful and inclusive
- Help others when you can
- Share your knowledge and experiences
- Provide constructive feedback
- Follow the [Code of Conduct](https://github.com/clement-fouque/elastic-integrations-standalone/blob/main/CODE_OF_CONDUCT.md)

## Questions?

- Open an issue for questions about contributing
- Join discussions in existing issues and PRs
- Check the [Elastic Community Forums](https://discuss.elastic.co/)

## Recognition

Contributors will be recognized in:
- Git commit history
- Release notes (for significant contributions)
- Project documentation (where applicable)

Thank you for contributing! 🎉
