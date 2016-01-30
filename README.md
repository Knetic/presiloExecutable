presiloExecutable
====

This is the canonical `presilo` binary executable project. It's fairly thin, and served mostly to provide a binary that fully implements the [presilo library](http://github.com/Knetic/presilo). The library itself is where the parsing/codegen logic lives.

How do I use it?
====

Start with a \*.json file whose contents describe your schema. See the [json-schema](http://json-schema.org/examples.html) examples for how to do this. Let's say our schema looks like this;

    {
    	"type": "object",
    	"title": "Person",
    	"properties":
    	{
    		"firstName":
    		{
    			"type": "string"
    		},
    		"lastName":
    		{
    			"type": "string"
    		},
    		"age":
    		{
    			"description": "Age in years",
    			"type": "integer",
    			"minimum": 0
    		}
    	},
    	"required": ["firstName", "lastName"]
    }

Then, run `presilo` on that file, and describe which language you'd like to have generated, and the output file.

    presilo -l go schema.json

This will generate a file called "Person.go". The name of the file is taken from the "title" field inside the schema itself. The contents of the generated file will contain a single struct definition, which ought to look like this;

    package main

    import (
        "errors"
    )

    type Person struct {

        firstName string
        lastName string
        age int
    }

    func NewPerson(firstName string, lastName string) *Person {

        var ret *schema

        ret = new(schema)
        ret.firstName = firstName
        ret.lastName = lastName

        return ret
    }

    func (this *Person) SetAge(value int) error {

        if(value < 0) {
            return errors.New("'age' must be greater than 0")
        }

        this.age = value
        return nil
    }

Sometimes your schema will have a nested schema, where one object contains another one. This will generate multiple files, one for each schema. Like so;

    {
        "title": "Car",
        "type": "object",
        "properties":
        {
            "seats"
            {
                "type": "integer",
                "minimum": "1",
                "maximum": "4"
            },
            "wheels":
            {
                "type": "array",
                "items":
                {
                    "oneOf":
                    [
                        {
                            "type": "object",
                            "title": "Tire",
                            "properties":
                            {
                                "weight":
                                {
                                    "type": "float",
                                    "minimum": "0"
                                },
                                "material":
                                {
                                    "type": "string",
                                    "enum": ["rubber", "unobtanium"]
                                }
                            }
                        }
                    ]
                }
            }
        }
    }

This will generate both Car.go and Tire.go, each containing the relevant data model and associated functions. The "Car" model will actually reference the "Tire" model. Note that if there are multiple schemas with the same title, an error will be given. You _must_ uniquely name your models.

That's cool, but not everyone uses Go. What about other languages? Using `-a` lists all supported languages.

    presilo -a

All supported languages have some form of "module" notion, which should be specified by the `-m` flag. For instance:

    presilo -l go -m awesome schema.json

Will make it so that instead of `package main`, the generated files will be listed as `package awesome`. Languages with nested package names (Java, Ruby, C#) will accept the dot-notation to separate package names (`com.awesome.project`, for example). If you give nested package names and tell `presilo` to generate a schema for a language which does not support them, it will give you an error.
