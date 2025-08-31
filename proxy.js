// Importar las dependencias necesarias
const express = require('express');
const axios = require('axios');
const cors = require('cors');
require('dotenv').config(); // Para cargar las variables de entorno desde un archivo .env

// Crear una instancia de la aplicación Express
const app = express();
const PORT = process.env.PORT || 3000;

// Middleware para permitir CORS
app.use(cors());

// Middleware para parsear JSON en las solicitudes
app.use(express.json());

// Endpoint /api/index
app.post('/api/index', async (req, res) => {
  try {
    // Validar el cuerpo de la solicitud
    const { tripId } = req.body;
    if (!tripId) {
      return res.status(400).json({ error: 'El campo tripId es obligatorio.' });
    }

    // Llamar a la función Edge de Supabase
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

    // Devolver la respuesta de la función Edge al cliente
    res.status(response.status).json(response.data);
  } catch (error) {
    console.error('Error al llamar a la función Edge:', error.message);
    if (error.response) {
      // Si la función Edge devolvió un error, reenviar el error al cliente
      res.status(error.response.status).json(error.response.data);
    } else {
      // Si hubo un error de red u otro problema
      res.status(500).json({ error: 'Error interno del servidor.' });
    }
  }
});

// Iniciar el servidor
app.listen(PORT, () => {
  console.log(`Proxy backend escuchando en http://localhost:${PORT}`);
});

/*
Ejemplo de configuración de variables de entorno (.env):

SUPABASE_URL=https://<project-ref>.supabase.co
SUPABASE_ANON_KEY=<tu-anon-key>
PORT=3000
*/
