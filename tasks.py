from invoke import task
import jinja2

@task
def configure(ctx):
    """Create an environment file from a template."""
    template = jinja2.Template(open('environment.j2').read())
    kwargs = dict(neo4j_password=input('Enter the Neo4j password: '),
                  venv=input('Enter path to venv: '))
    with open('.environment', 'w') as dst:
        dst.write(template.render(**kwargs))
