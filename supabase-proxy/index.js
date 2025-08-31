// ----------------------
// Importar dependencias
// ----------------------
const express = require('express');
const axios = require('axios');
const cors = require('cors');

// ----------------------
// Crear la app Express
// ----------------------
const app = express();
const PORT = process.env.PORT || 3000;

// ----------------------
// Middleware
// ----------------------
app.use(cors()); // Permite solicitudes desde cualquier origen
app.use(express.json()); // Parsear JSON

// ----------------------
// Endpoint principal
// ----------------------
app.post('/api/index', async (req, res) => {
  try {
    const { tripId } = req.body;

    if (!tripId) {
      return res.status(400).json({ error: 'El campo tripId es obligatorio.' });
    }

    // Llamada a la función Edge de Supabase
    const response = await axios.post(
      `${process.env.SUPABASE_URL}/functions/v1/index`,
      { tripId },
      {
        headers: {
          'Content-Type': 'application/json',
          apikey: process.env.SUPABASE_ANON_KEY,
          Authorization: `Bearer ${process.env.SUPABASE_ANON_KEY}`,
        },
      }
    );

    // Retornar la respuesta de la función Edge
    res.status(response.status).json(response.data);
  } catch (error) {
    console.error('Error al llamar a la función Edge:', error.message);

    if (error.response) {
      res.status(error.response.status).json(error.response.data);
    } else {
      res.status(500).json({ error: 'Error interno del servidor.' });
    }
  }
});

// ----------------------
// Iniciar servidor
// ----------------------
app.listen(PORT, () => {
  console.log(`Proxy backend escuchando en puerto ${PORT}`);
});
