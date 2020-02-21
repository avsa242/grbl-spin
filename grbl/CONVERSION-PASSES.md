1. Basic (automatic) syntax replacement
2. Remove prototypes from headers
3. Hand-convert more syntax
4. Confirm block ranges/indentation levels
5. Convert unsupported preprocessor extensions (complex macros)

x. Formatting
    a. Remove trailing whitespace
    b. Format per spin-std-lib contrib guidelines

x. sys. convert to object?
x. Handle floating point parse/display
x. Handle Interrupts - dedicated cog with flag to set relevant "soft" interrupt?
x. Structures - convert to child objects? provide baseaddr method
    then, e.g., plan_line_data_t would be a child object (plan_line_data_t.spin)
    to use as a structure:

    plan_line_data_t.spin:

    VAR

        long _member1
        byte _member0
        byte _member

    PUB member1(val)

        case val
            ok_range:
                _member1 := val
            OTHER:
                return _member1

    parent_object_file.spin:

    OBJ

        plan_data       : "plan_line_data_t"

    PUB SomeMethod

        plan_data.member(45)            ' instead of C: plan_data.member = 45;
        if plan_data.member == 45       ' Same syntax

