#!/usr/bin/env node

/**
 * Import CSV data into Supabase
 * 
 * Usage:
 *   node import-data.js
 * 
 * Make sure to set DATABASE_URL environment variable:
 *   DATABASE_URL=postgresql://postgres:your-password@localhost:54322/postgres node import-data.js
 */

const fs = require('fs');
const path = require('path');
const { Client } = require('pg');

// Parse CSV line (handles quoted fields with commas)
function parseCSVLine(line) {
  const result = [];
  let current = '';
  let inQuotes = false;
  
  for (let i = 0; i < line.length; i++) {
    const char = line[i];
    const nextChar = line[i + 1];
    
    if (char === '"') {
      if (inQuotes && nextChar === '"') {
        current += '"';
        i++; // Skip next quote
      } else {
        inQuotes = !inQuotes;
      }
    } else if (char === ',' && !inQuotes) {
      result.push(current.trim());
      current = '';
    } else {
      current += char;
    }
  }
  result.push(current.trim());
  return result;
}

// Read and parse CSV file
function readCSV(filePath) {
  const content = fs.readFileSync(filePath, 'utf-8');
  const lines = content.split('\n').filter(line => line.trim());
  const headers = parseCSVLine(lines[0]);
  const rows = [];
  
  for (let i = 1; i < lines.length; i++) {
    const values = parseCSVLine(lines[i]);
    if (values.length === headers.length) {
      const row = {};
      headers.forEach((header, index) => {
        row[header] = values[index] || null;
      });
      rows.push(row);
    }
  }
  
  return rows;
}

async function importData() {
  const client = new Client({
    connectionString: process.env.DATABASE_URL || 'postgresql://postgres:your-super-secret-jwt-token-with-at-least-32-characters-long@localhost:54322/postgres',
  });

  try {
    await client.connect();
    console.log('Connected to database');

    // Read CSV files
    const haushaltePath = path.join(__dirname, 'Haushalte.csv');
    const personenPath = path.join(__dirname, 'Personen.csv');

    console.log('Reading Haushalte.csv...');
    const haushalteData = readCSV(haushaltePath);
    console.log(`Found ${haushalteData.length} households`);

    console.log('Reading Personen.csv...');
    const personenData = readCSV(personenPath);
    console.log(`Found ${personenData.length} people`);

    // Import Haushalte
    console.log('\nImporting households...');
    const haushaltMap = new Map(); // Map address to UUID
    
    for (const row of haushalteData) {
      const haus = row.Haus?.trim();
      if (!haus) continue;

      const result = await client.query(
        `INSERT INTO haushalte (haus, bemerkung, pipeline_status, tasks, vermietet)
         VALUES ($1, $2, $3, $4, $5)
         ON CONFLICT (haus) DO UPDATE SET
           bemerkung = EXCLUDED.bemerkung,
           pipeline_status = EXCLUDED.pipeline_status,
           tasks = EXCLUDED.tasks,
           vermietet = EXCLUDED.vermietet
         RETURNING id, haus`,
        [
          haus,
          row.Bemerkung || null,
          row['Pipeline Status'] || null,
          row.Tasks || null,
          row.Vermietet === 'checked' || row.Vermietet === 'true'
        ]
      );
      
      haushaltMap.set(haus, result.rows[0].id);
      console.log(`  ✓ Imported: ${haus}`);
    }

    // Import Personen
    console.log('\nImporting people...');
    for (const row of personenData) {
      const name = row.Name?.trim();
      if (!name) continue;

      // Handle multiple addresses (comma-separated)
      const haushaltAddresses = row.Haushalt?.split(',').map(a => a.trim()).filter(Boolean) || [];
      
      // Try to find matching haushalt_id
      let haushaltId = null;
      if (haushaltAddresses.length > 0) {
        for (const address of haushaltAddresses) {
          if (haushaltMap.has(address)) {
            haushaltId = haushaltMap.get(address);
            break;
          }
        }
      }

      await client.query(
        `INSERT INTO personen (name, email, telefonnummer, haushalt_id, haushalt_address, notizen, vermietet)
         VALUES ($1, $2, $3, $4, $5, $6, $7)
         ON CONFLICT DO NOTHING`,
        [
          name,
          row['E-Mail Adresse']?.trim() || null,
          row.Telefonnummer?.trim() || null,
          haushaltId,
          row.Haushalt?.trim() || null,
          row.Notizen?.trim() || null,
          row.Vermietet?.trim() || null
        ]
      );
      
      console.log(`  ✓ Imported: ${name}`);
    }

    console.log('\n✅ Data import completed successfully!');
    
    // Show summary
    const haushalteCount = await client.query('SELECT COUNT(*) FROM haushalte');
    const personenCount = await client.query('SELECT COUNT(*) FROM personen');
    
    console.log(`\nSummary:`);
    console.log(`  Households: ${haushalteCount.rows[0].count}`);
    console.log(`  People: ${personenCount.rows[0].count}`);

  } catch (error) {
    console.error('Error importing data:', error);
    process.exit(1);
  } finally {
    await client.end();
  }
}

importData();




