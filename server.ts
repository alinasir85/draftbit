import "dotenv/config";
import {Client} from "pg";
import express from "express";
import waitOn from "wait-on";
import onExit from "signal-exit";
import cors from "cors";

// Add your routes here
const setupApp = (client: Client): express.Application => {
    const app: express.Application = express();

    app.use(cors());

    app.use(express.json());

    app.get("/examples", async (_req, res) => {
        const {rows} = await client.query(`SELECT *
                                           FROM example_table`);
        res.json(rows);
    });

    app.get("/spacing-values", async (_req, res) => {
        try {
            const {rows} = await client.query(`SELECT *
                                               FROM spacing_values
                                               LIMIT 1`);
            if (rows.length > 0) {
                res.json(rows[0]);
            } else {
                res.status(404).json({message: "No spacing values found"});
            }
        } catch (error) {
            console.error("Error fetching spacing values:", error);
            res.status(500).json({error: "Internal server error"});
        }
    });

    app.post("/spacing-values", async (req, res) => {
        const {
            id,
            marginLeft,
            isMarginLeftFocused,
            marginRight,
            isMarginRightFocused,
            marginTop,
            isMarginTopFocused,
            marginBottom,
            isMarginBottomFocused,
            paddingLeft,
            isPaddingLeftFocused,
            paddingRight,
            isPaddingRightFocused,
            paddingTop,
            isPaddingTopFocused,
            paddingBottom,
            isPaddingBottomFocused
        } = req.body;

        try {
            let result;
            if (id) {
                result = await client.query(`
                    UPDATE spacing_values
                    SET margin_left               = $1,
                        is_margin_left_focused    = $2,
                        margin_right              = $3,
                        is_margin_right_focused   = $4,
                        margin_top                = $5,
                        is_margin_top_focused     = $6,
                        margin_bottom             = $7,
                        is_margin_bottom_focused  = $8,
                        padding_left              = $9,
                        is_padding_left_focused   = $10,
                        padding_right             = $11,
                        is_padding_right_focused  = $12,
                        padding_top               = $13,
                        is_padding_top_focused    = $14,
                        padding_bottom            = $15,
                        is_padding_bottom_focused = $16
                    WHERE id = $17
                    RETURNING id
                `, [
                    marginLeft,
                    isMarginLeftFocused,
                    marginRight,
                    isMarginRightFocused,
                    marginTop,
                    isMarginTopFocused,
                    marginBottom,
                    isMarginBottomFocused,
                    paddingLeft,
                    isPaddingLeftFocused,
                    paddingRight,
                    isPaddingRightFocused,
                    paddingTop,
                    isPaddingTopFocused,
                    paddingBottom,
                    isPaddingBottomFocused,
                    id
                ]);
            } else {
                result = await client.query(`
                    INSERT INTO spacing_values (margin_left,
                                                is_margin_left_focused,
                                                margin_right,
                                                is_margin_right_focused,
                                                margin_top,
                                                is_margin_top_focused,
                                                margin_bottom,
                                                is_margin_bottom_focused,
                                                padding_left,
                                                is_padding_left_focused,
                                                padding_right,
                                                is_padding_right_focused,
                                                padding_top,
                                                is_padding_top_focused,
                                                padding_bottom,
                                                is_padding_bottom_focused)
                    VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16)
                    RETURNING id
                `, [
                    marginLeft,
                    isMarginLeftFocused,
                    marginRight,
                    isMarginRightFocused,
                    marginTop,
                    isMarginTopFocused,
                    marginBottom,
                    isMarginBottomFocused,
                    paddingLeft,
                    isPaddingLeftFocused,
                    paddingRight,
                    isPaddingRightFocused,
                    paddingTop,
                    isPaddingTopFocused,
                    paddingBottom,
                    isPaddingBottomFocused
                ]);
            }
            res.json({message: "Operation successful", id: result.rows[0].id});
        } catch (error) {
            console.error("Error processing spacing values:", error);
            res.status(500).json({error: "Internal server error"});
        }
    });

    return app;
};

// Waits for the database to start and connects
const connect = async (): Promise<Client> => {
    console.log("Connecting");
    const resource = `tcp:${process.env.PGHOST}:${process.env.PGPORT}`;
    console.log(`Waiting for ${resource}`);
    await waitOn({resources: [resource]});
    console.log("Initializing client");
    const client = new Client();
    await client.connect();
    console.log("Connected to database");

    // Ensure the client disconnects on exit
    onExit(async () => {
        console.log("onExit: closing client");
        await client.end();
    });

    return client;
};

const main = async () => {
    const client = await connect();
    const app = setupApp(client);
    const port = parseInt(process.env.SERVER_PORT);
    app.listen(port, () => {
        console.log(
            `Draftbit Coding Challenge is running at http://localhost:${port}/`
        );
    });
};

main();
