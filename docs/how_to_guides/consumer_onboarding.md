# Consumer Onboarding Guide

## Overview

This guide walks you through setting up and onboarding to the Agentic Data Engineer framework as a consumer. Whether you're starting a greenfield project or integrating with an existing brownfield project, this guide will help you get started.

## Prerequisites

Before you begin, ensure you have the following installed:

1. **Python 3.12+**: Required for the framework
2. **pyenv**: For Python version management
3. **Copier**: Template management tool

### Step 0 - Prerequisites

> ⚠️ **Don't skip this step!**

#### 1. Complete Mac Environment Setup

Follow the guide: [HOW-TO Environment setup - Mac - Data Engineering](https://skyscanner.atlassian.net/wiki/spaces/ADE/pages/1971322970)

#### 2. Authenticate with Artifactory

**This is critical for setup success!**

```bash
# 1. Add Skyscanner homebrew tap
brew tap skyscanner/mshell git@github.com:Skyscanner/homebrew-mshell.git

# 2. Install Artifactory CLI login tool
brew install artifactory-cli-login

# 3. Login to Artifactory (overwrites ~/.pip/pip.conf)
mshell artifactory login -f
```

You will be prompted for:
- **Skyscanner email**: `firstname.lastname@skyscanner.net`
- **Okta password**: Your Skyscanner password

**Note**: Username can be either:
- `firstname.lastname` OR
- `firstname.lastname@skyscanner.net`

**More info**: [Onboard Artifactory to Okta Authentication](https://skyscanner.atlassian.net/wiki/spaces/DAT/pages/onboard-artifactory)


#### 3. Install Copier

```bash
pip install copier
```

---

## Consumer Flow Overview

## Path 1: Greenfield Projects (New Projects)

Follow [this](consumer_onboarding_greenfield.md) path when starting a brand new data engineering project.

## Path 2: Brownfield Projects (Existing Projects)

**Status**: 🚧 To Be Determined (TBD)

If you're integrating the Agentic Data Engineer framework into an existing project, the detailed steps are currently being developed.

**Recommended Approach** (Interim):
1. Review your existing project structure
2. Consider starting with a greenfield template and gradually migrating components
3. Contact the framework team for guidance on brownfield migration


---

# [Troubleshooting](./troubleshooting.md)

---
## Best Practices

### Version Management

1. **Always use tagged versions**: Never use `main` or `master` branch directly
2. **Check release notes**: Review what changed before updating
3. **Test after updates**: Run full test suite after template updates

### Project Organization

1. **Use feature branches**: Never commit directly to `main`
2. **Keep customizations separate**: Document any deviations from template
3. **Regular updates**: Pull template updates regularly to avoid large conflicts

### Development Environment

1. **Use virtual environments**: Always activate pyenv before working
2. **Pin dependencies**: Use Poetry lock files for reproducibility
3. **Document setup**: Keep a team README for project-specific setup steps

### Collaboration

1. **Shared conventions**: Follow the template's coding standards
2. **Document changes**: Update project docs when customizing template
3. **Team alignment**: Ensure all team members follow same onboarding process

## Validation Checklist

After completing onboarding, verify the following:

- [ ] Copier is installed and accessible
- [ ] Python 3.12+ is installed via pyenv
- [ ] Project generated successfully from template
- [ ] Virtual environment activated
- [ ] All dependencies installed via Poetry
- [ ] Git repository initialized and connected to remote
- [ ] Databricks authentication configured
- [ ] `mcp` command works
- [ ] `agents` command works
- [ ] `make test` passes
- [ ] `make lint` passes
- [ ] Can run agents successfully
- [ ] Team members can replicate setup

## Next Steps

After successful onboarding:

1. **Review Documentation**:
   - Read the framework architecture docs
   - Explore available agents and their capabilities
   - Review coding standards and patterns

2. **Join the Community**:
   - Join team Slack channels
   - Share feedback and suggestions

3. **Start Building**:
   - Implement transformations
   - Create your first data pipeline   
   - Configure agents for your use case

## Support and Resources

### Documentation

- **Framework Docs**: `/docs/` in your project
- **How-To Guides**: `/docs/how_to_guides/`

### Getting Help

- **Slack**: [#agentic-data-engineer](https://skyscanner.slack.com/archives/agentic-data-engineer)
- **GitHub Issues**: https://github.com/Skyscanner/agentic-data-engineer/issues
- **Team Wiki**: [Link to your team's wiki]

### Template Repository

- **Source**: https://github.com/Skyscanner/data-nova-copier
- **Releases**: https://github.com/Skyscanner/data-nova-copier/releases
- **Changelog**: Review release notes for updates

## Appendix

### Makefile Targets

Common `make` targets available in generated projects:

| Target | Description |
|--------|-------------|
| `make help` | Display all available targets |
| `make project-pyenv-init` | Initialize Python environment |
| `make project-init` | Initialize project dependencies |
| `make test` | Run test suite |
| `make lint` | Run linters (ruff) |
| `make format` | Format code |
| `make clean` | Clean build artifacts |

---

**Document Version**: 1.0
**Last Updated**: 2026-01-23
**Maintained By**: Agentic Data Engineer Team
