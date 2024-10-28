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
    id                        SERIAL PRIMARY KEY,
    margin_left               TEXT,
    is_margin_left_focused    BOOLEAN,
    margin_right              TEXT,
    is_margin_right_focused   BOOLEAN,
    margin_top                TEXT,
    is_margin_top_focused     BOOLEAN,
    margin_bottom             TEXT,
    is_margin_bottom_focused  BOOLEAN,
    padding_left              TEXT,
    is_padding_left_focused   BOOLEAN,
    padding_right             TEXT,
    is_padding_right_focused  BOOLEAN,
    padding_top               TEXT,
    is_padding_top_focused    BOOLEAN,
    padding_bottom            TEXT,
    is_padding_bottom_focused BOOLEAN
);
