# Temple

Temple is a basic template engine written for Cyclone Scheme.

The syntax is loosely based off of [Jinja templates](https://jinja.palletsprojects.com/en/2.11.x/templates/#variables). However, the goal of Temple is to embed Scheme code with the tags.

# Syntax 

Scheme code may be embedded in one of the following sets of tags:

    {% ... %} for Statements (no output)
    
    {{ ... }} for Expressions to print to the template output

    {# ... #} for Comments not included in the template output

# Examples

