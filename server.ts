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

    app.patch("/spacing-values/:id", async (req, res) => {
        const {id} = req.params;
        const fieldsToUpdate = req.body;

        const validFields = [
            'marginLeft', 'marginRight', 'marginTop', 'marginBottom',
            'paddingLeft', 'paddingRight', 'paddingTop', 'paddingBottom',
        ];

        const updates = Object.entries(fieldsToUpdate).filter(([key, value]) =>
            validFields.includes(key) && value !== undefined
        );

        if (updates.length === 0) {
            return res.status(400).json({error: "No valid fields to update"});
        }

        const setClauses = updates.map(([key], index) => {
            const dbField = key.replace(/([A-Z])/g, '_$1').toLowerCase();
            return `${dbField} = $${index + 1}`;
        });

        const queryParams = updates.map(([, value]) => value);
        queryParams.push(id);

        const query = `
            UPDATE spacing_values
            SET ${setClauses.join(", ")}
            WHERE id = $${queryParams.length}
        RETURNING id;
    `;

        try {
            const result = await client.query(query, queryParams);
            if (result.rowCount === 0) {
                return res.status(404).json({error: "Record not found"});
            }
            res.json({message: "Update successful", id: result.rows[0].id});
        } catch (error) {
            console.error("Error updating spacing values:", error);
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
