# Contributing to YAMS - Yet Another Media Server

*Guidelines for contributing to the YAMS project.*

Thank you for your interest in contributing to YAMS! We appreciate your help in making this project better.

## Table of Contents

- [Contributing to YAMS - Yet Another Media Server](#contributing-to-yams---yet-another-media-server)
  - [Table of Contents](#table-of-contents)
  - [Project layout](#project-layout)
  - [Getting Started](#getting-started)
  - [Local development environment](#local-development-environment)
  - [Code of Conduct](#code-of-conduct)
  - [Questions and Support](#questions-and-support)

---

## Project layout

The entire YAMS project is contained within a single repository.

- `src/` - Things related to the installer including the setup script and the docker compose templates
- `docs/` - Hugo-based website content and guides
- `tests/` - automated Bats-based validation for the installer and CLI

If you are making a change to the documentation/guides you should only need to edit files inside the `docs/` folder.

## Getting Started

1. **Fork the Repository**: Start by forking the YAMS repository on GitLab by clicking the "Fork" button at the top right of the repository page: [YAMS on GitLab](https://github.com/rogsme/yams).

2. **Clone Your Fork**: Clone your forked repository to your local development environment:

   ```bash
   git clone https://github.com/your-username/yams.git
   cd yams
   ```

3. **Create a New Branch**: Create a feature branch for your work.

   ```bash
   git checkout -b your-branch-name
   ```

4. **Make Changes**: Make the necessary code changes, additions, or improvements in your branch. Ensure that your code follows our coding standards and guidelines.

5. **Test Your Changes**: Test your changes to ensure they work as expected and do not introduce any new issues.

6. **Commit Your Changes**: Commit your changes with a descriptive commit message.
   ```bash
   git add .
   git commit -m "Your descriptive commit message"
   ```

7. **Push Your Changes**: Push your branch to your fork.

   ```bash
   git push origin your-branch-name
   ```

8. **Open a Pull Request**: Open a pull request against the main YAMS repository and describe the change, why it is needed, and any validation you ran.

9. **Review and Collaborate**: Maintainers may ask for adjustments. Be prepared to iterate on any changes and keep the repo conventions in mind.


## Local development environment

For local work, a couple of tools are required depending on what you are changing:

- Docs: install Hugo and run the site from the `docs/` directory:

  ```bash
  cd docs
  hugo server
  ```

- Tests: Docker is required for the repo's automated validation:

  ```bash
  tests/run
  ```

  The test suite is designed to run in Docker.

## Code of Conduct

Basically, don't be an asshole. You can read our Code of Conduct here: [CODE_OF_CONDUCT.md](https://gitlab.com/rogs/yams/-/blob/master/CODE_OF_CONDUCT.md)

## Questions and Support

If you have any questions while contributing, feel free to reach out through the project community: [our forums](https://forum.yams.media/) or [Discord](https://discord.gg/Gwae3tNMST).

Thank you for helping make YAMS better!
