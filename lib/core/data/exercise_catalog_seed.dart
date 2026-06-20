// Catálogo base de ejercicios para FitNexus
// cada entrada: nombre, musculo, equipo

const List<Map<String, String>> exerciseCatalogSeed = [
  // PECHO
  {'nombre': 'Press de banca plano', 'musculo': 'Pecho', 'equipo': 'Barra'},
  {'nombre': 'Press de banca inclinado', 'musculo': 'Pecho', 'equipo': 'Barra'},
  {'nombre': 'Press de banca declinado', 'musculo': 'Pecho', 'equipo': 'Barra'},
  {'nombre': 'Press con mancuernas plano', 'musculo': 'Pecho', 'equipo': 'Mancuerna'},
  {'nombre': 'Press con mancuernas inclinado', 'musculo': 'Pecho', 'equipo': 'Mancuerna'},
  {'nombre': 'Aperturas con mancuernas', 'musculo': 'Pecho', 'equipo': 'Mancuerna'},
  {'nombre': 'Cruces en polea (cable fly)', 'musculo': 'Pecho', 'equipo': 'Polea'},
  {'nombre': 'Press en máquina', 'musculo': 'Pecho', 'equipo': 'Máquina'},
  {'nombre': 'Pec deck (contractora)', 'musculo': 'Pecho', 'equipo': 'Máquina'},
  {'nombre': 'Fondos en paralelas', 'musculo': 'Pecho', 'equipo': 'Peso corporal'},
  {'nombre': 'Flexiones de pecho', 'musculo': 'Pecho', 'equipo': 'Peso corporal'},
  {'nombre': 'Pullover con mancuerna', 'musculo': 'Pecho', 'equipo': 'Mancuerna'},

  // ESPALDA
  {'nombre': 'Dominadas', 'musculo': 'Espalda', 'equipo': 'Peso corporal'},
  {'nombre': 'Jalón al pecho en polea', 'musculo': 'Espalda', 'equipo': 'Polea'},
  {'nombre': 'Jalón tras nuca', 'musculo': 'Espalda', 'equipo': 'Polea'},
  {'nombre': 'Remo con barra', 'musculo': 'Espalda', 'equipo': 'Barra'},
  {'nombre': 'Remo con mancuerna a una mano', 'musculo': 'Espalda', 'equipo': 'Mancuerna'},
  {'nombre': 'Remo en polea baja (seated row)', 'musculo': 'Espalda', 'equipo': 'Polea'},
  {'nombre': 'Remo en máquina', 'musculo': 'Espalda', 'equipo': 'Máquina'},
  {'nombre': 'Peso muerto', 'musculo': 'Espalda', 'equipo': 'Barra'},
  {'nombre': 'Peso muerto rumano', 'musculo': 'Espalda', 'equipo': 'Barra'},
  {'nombre': 'Hiperextensiones', 'musculo': 'Espalda', 'equipo': 'Peso corporal'},
  {'nombre': 'Pull-over en polea alta', 'musculo': 'Espalda', 'equipo': 'Polea'},
  {'nombre': 'Face pull', 'musculo': 'Espalda', 'equipo': 'Polea'},

  // HOMBROS
  {'nombre': 'Press militar con barra', 'musculo': 'Hombros', 'equipo': 'Barra'},
  {'nombre': 'Press de hombro con mancuernas', 'musculo': 'Hombros', 'equipo': 'Mancuerna'},
  {'nombre': 'Press Arnold', 'musculo': 'Hombros', 'equipo': 'Mancuerna'},
  {'nombre': 'Elevaciones laterales', 'musculo': 'Hombros', 'equipo': 'Mancuerna'},
  {'nombre': 'Elevaciones frontales', 'musculo': 'Hombros', 'equipo': 'Mancuerna'},
  {'nombre': 'Pájaros (elevación posterior)', 'musculo': 'Hombros', 'equipo': 'Mancuerna'},
  {'nombre': 'Press de hombro en máquina', 'musculo': 'Hombros', 'equipo': 'Máquina'},
  {'nombre': 'Elevaciones laterales en polea', 'musculo': 'Hombros', 'equipo': 'Polea'},
  {'nombre': 'Remo al cuello (upright row)', 'musculo': 'Hombros', 'equipo': 'Barra'},
  {'nombre': 'Encogimientos de hombros (shrugs)', 'musculo': 'Hombros', 'equipo': 'Mancuerna'},

  // BÍCEPS
  {'nombre': 'Curl con barra', 'musculo': 'Bíceps', 'equipo': 'Barra'},
  {'nombre': 'Curl con mancuernas', 'musculo': 'Bíceps', 'equipo': 'Mancuerna'},
  {'nombre': 'Curl martillo', 'musculo': 'Bíceps', 'equipo': 'Mancuerna'},
  {'nombre': 'Curl en banco scott', 'musculo': 'Bíceps', 'equipo': 'Barra'},
  {'nombre': 'Curl en polea baja', 'musculo': 'Bíceps', 'equipo': 'Polea'},
  {'nombre': 'Curl concentrado', 'musculo': 'Bíceps', 'equipo': 'Mancuerna'},
  {'nombre': 'Curl en máquina', 'musculo': 'Bíceps', 'equipo': 'Máquina'},

  // TRÍCEPS
  {'nombre': 'Press francés', 'musculo': 'Tríceps', 'equipo': 'Barra'},
  {'nombre': 'Extensión de tríceps en polea', 'musculo': 'Tríceps', 'equipo': 'Polea'},
  {'nombre': 'Extensión de tríceps sobre la cabeza', 'musculo': 'Tríceps', 'equipo': 'Mancuerna'},
  {'nombre': 'Patada de tríceps', 'musculo': 'Tríceps', 'equipo': 'Mancuerna'},
  {'nombre': 'Fondos de tríceps en banco', 'musculo': 'Tríceps', 'equipo': 'Peso corporal'},
  {'nombre': 'Press cerrado en banca', 'musculo': 'Tríceps', 'equipo': 'Barra'},
  {'nombre': 'Extensión en máquina', 'musculo': 'Tríceps', 'equipo': 'Máquina'},

  // PIERNAS - CUÁDRICEPS
  {'nombre': 'Sentadilla con barra', 'musculo': 'Piernas', 'equipo': 'Barra'},
  {'nombre': 'Sentadilla frontal', 'musculo': 'Piernas', 'equipo': 'Barra'},
  {'nombre': 'Prensa de piernas', 'musculo': 'Piernas', 'equipo': 'Máquina'},
  {'nombre': 'Extensión de cuádriceps', 'musculo': 'Piernas', 'equipo': 'Máquina'},
  {'nombre': 'Zancadas con mancuernas', 'musculo': 'Piernas', 'equipo': 'Mancuerna'},
  {'nombre': 'Sentadilla búlgara', 'musculo': 'Piernas', 'equipo': 'Mancuerna'},
  {'nombre': 'Sentadilla goblet', 'musculo': 'Piernas', 'equipo': 'Mancuerna'},
  {'nombre': 'Hack squat', 'musculo': 'Piernas', 'equipo': 'Máquina'},

  // PIERNAS - FEMORAL Y GLÚTEO
  {'nombre': 'Curl femoral acostado', 'musculo': 'Piernas', 'equipo': 'Máquina'},
  {'nombre': 'Curl femoral sentado', 'musculo': 'Piernas', 'equipo': 'Máquina'},
  {'nombre': 'Hip thrust', 'musculo': 'Piernas', 'equipo': 'Barra'},
  {'nombre': 'Puente de glúteo', 'musculo': 'Piernas', 'equipo': 'Peso corporal'},
  {'nombre': 'Patada de glúteo en polea', 'musculo': 'Piernas', 'equipo': 'Polea'},
  {'nombre': 'Abducción de cadera en máquina', 'musculo': 'Piernas', 'equipo': 'Máquina'},

  // PANTORRILLAS
  {'nombre': 'Elevación de talones de pie', 'musculo': 'Piernas', 'equipo': 'Máquina'},
  {'nombre': 'Elevación de talones sentado', 'musculo': 'Piernas', 'equipo': 'Máquina'},
  {'nombre': 'Elevación de talones en prensa', 'musculo': 'Piernas', 'equipo': 'Máquina'},

  // ABDOMEN / CORE
  {'nombre': 'Plancha (plank)', 'musculo': 'Abdomen', 'equipo': 'Peso corporal'},
  {'nombre': 'Crunch abdominal', 'musculo': 'Abdomen', 'equipo': 'Peso corporal'},
  {'nombre': 'Elevación de piernas colgado', 'musculo': 'Abdomen', 'equipo': 'Peso corporal'},
  {'nombre': 'Rueda rusa (Russian twist)', 'musculo': 'Abdomen', 'equipo': 'Peso corporal'},
  {'nombre': 'Crunch en polea alta', 'musculo': 'Abdomen', 'equipo': 'Polea'},
  {'nombre': 'Encogimientos en máquina', 'musculo': 'Abdomen', 'equipo': 'Máquina'},
  {'nombre': 'Mountain climbers', 'musculo': 'Abdomen', 'equipo': 'Peso corporal'},
  {'nombre': 'Ab wheel rollout', 'musculo': 'Abdomen', 'equipo': 'Peso corporal'},

  // CARDIO
  {'nombre': 'Correr en caminadora', 'musculo': 'Cardio', 'equipo': 'Máquina'},
  {'nombre': 'Bicicleta estática', 'musculo': 'Cardio', 'equipo': 'Máquina'},
  {'nombre': 'Elíptica', 'musculo': 'Cardio', 'equipo': 'Máquina'},
  {'nombre': 'Remo (máquina de remo)', 'musculo': 'Cardio', 'equipo': 'Máquina'},
  {'nombre': 'Saltar la cuerda', 'musculo': 'Cardio', 'equipo': 'Peso corporal'},
  {'nombre': 'Burpees', 'musculo': 'Cardio', 'equipo': 'Peso corporal'},
  {'nombre': 'Escaladora (stair climber)', 'musculo': 'Cardio', 'equipo': 'Máquina'},
  {'nombre': 'Sprints', 'musculo': 'Cardio', 'equipo': 'Peso corporal'},

  // ANTEBRAZO
  {'nombre': 'Curl de muñeca', 'musculo': 'Antebrazo', 'equipo': 'Barra'},
  {'nombre': 'Curl de muñeca inverso', 'musculo': 'Antebrazo', 'equipo': 'Barra'},
  {'nombre': 'Farmer walk', 'musculo': 'Antebrazo', 'equipo': 'Mancuerna'},
];