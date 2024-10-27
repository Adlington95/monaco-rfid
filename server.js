const express = require('express')
const pool = require('./db')
const cors = require('cors')
const port = 3000

const app = express()
app.use(express.json())
app.use(cors())
//GET all entries
app.get('/', async (req, res) => {
    try {
        const data = await pool.query('SELECT * FROM monaco')
        res.status(200).send(data.rows)
    } catch (err) {
        console.log(err)
        res.sendStatus(500)
    }
})

//POST new entry
app.post('/', async (req, res) => {
    const { name, lap_time, team_name } = req.body
    try {
        await pool.query('INSERT INTO monaco (name, lap_time, team_name) VALUES ($1, $2, $3)', [name, lap_time, team_name])
        res.status(200).send({ message: "Successfully inserted entry into moncaco" })
    } catch (err) {
        console.log(err)
        res.sendStatus(500)
    }
})

//CREATE TABLE
app.get('/setup', async (req, res) => {
    try {
        await pool.query('CREATE TABLE monaco( id SERIAL PRIMARY KEY, name VARCHAR(100), lap_time VARCHAR(100), team_name VARCHAR(100))')
        res.status(200).send({ message: "Successfully created table" })
    } catch (err) {
        console.log(err)
        res.sendStatus(500)
    }
})


app.listen(port, () => console.log(`Server has started on port: ${port}`))

