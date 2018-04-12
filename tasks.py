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

@task
def install(ctx, make_rdata=False, only_rdata=False):
    """Install the programminglanguages R package."""
    if make_rdata or only_rdata:
        ctx.run('Rscript bin/rdata.R', echo=True)
    if only_rdata:
        return
    ctx.run('Rscript -e "devtools::install()"', echo=True)
