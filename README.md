# Overview
A demo repository to illustrate a version controlled and containerised approach
for archiving reports:

- Coordinated via [Make](https://www.gnu.org/software/make/).
- Containers, managed via [podman](https://docs.podman.io/en/latest/), are used
  for the analysis runtime and generation of report output.
- Git used for version control.
- [Container](https://github.com/TimTaylor/demo-monkeypox/pkgs/container/monkeypox/35977654?tag=latest),
  [source](https://github.com/TimTaylor/demo-monkeypox) and
  [output](https://timtaylor.github.io/demo-monkeypox/) all hosted using GitHub
  services.
  
# Getting started
In an empty directory
```bash
# clone the demo repo
git clone https://github.com/TimTaylor/demo-monkeypox.git

# pull the container from the registry
docker pull ghcr.io/timtaylor/monkeypox:latest

# enter cloned repo
cd demo-monkeypox

# to list tag versions 
git tag

# build dev report
make report

# build earlier report
git checkout -f v1.0
make report

# current report
git checkout -f v1.1
make report

```
