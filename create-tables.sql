-- Create your database tables here. Alternatively you may use an ORM
-- or whatever approach you prefer to initialize your database.
CREATE TABLE example_table
(
    id        SERIAL PRIMARY KEY,
    some_int  INT,
    some_text TEXT
);
INSERT INTO example_table (some_int, some_text)
VALUES (123, 'hello');

CREATE TABLE spacing_values
(
    id             SERIAL PRIMARY KEY,
    margin_left    TEXT,
    margin_right   TEXT,
    margin_top     TEXT,
    margin_bottom  TEXT,
    padding_left   TEXT,
    padding_right  TEXT,
    padding_top    TEXT,
    padding_bottom TEXT
);

INSERT INTO spacing_values (margin_left,
                            margin_right,
                            margin_top,
                            margin_bottom,
                            padding_left,
                            padding_right,
                            padding_top,
                            padding_bottom)
VALUES ('',
        '',
        '',
        '',
        '',
        '',
        '',
        '');
