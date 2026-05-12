class SeedCourse {
  final String id;
  final String title;
  final String description;
  final List<SeedSubject> subjects;

  const SeedCourse({
    required this.id,
    required this.title,
    required this.description,
    required this.subjects,
  });
}

class SeedSubject {
  final String id;
  final String title;
  final List<SeedQuiz> quizzes;

  const SeedSubject({
    required this.id,
    required this.title,
    required this.quizzes,
  });
}

class SeedQuiz {
  final String id;
  final String title;
  final int duration;
  final List<SeedQuestion> questions;

  const SeedQuiz({
    required this.id,
    required this.title,
    required this.duration,
    required this.questions,
  });
}

class SeedQuestion {
  final String id;
  final String questionText;
  final List<String> options;
  final String correctAnswer;
  final String explanation;

  const SeedQuestion({
    required this.id,
    required this.questionText,
    required this.options,
    required this.correctAnswer,
    required this.explanation,
  });
}

const sampleCourses = <SeedCourse>[
  SeedCourse(
    id: 'sample_cs',
    title: 'Computer Science',
    description: 'Programming, databases, networking, and app fundamentals.',
    subjects: [
      SeedSubject(
        id: 'sample_cs_programming',
        title: 'Programming Basics',
        quizzes: [
          SeedQuiz(
            id: 'sample_cs_programming_core',
            title: 'Programming Core Concepts',
            duration: 12,
            questions: [
              SeedQuestion(
                id: 'sample_cs_programming_core_q1',
                questionText: 'Which keyword is commonly used to create a variable in Dart?',
                options: ['var', 'dim', 'let-only', 'newvar'],
                correctAnswer: 'var',
                explanation: 'Dart supports var for local variable type inference.',
              ),
              SeedQuestion(
                id: 'sample_cs_programming_core_q2',
                questionText: 'What does a loop help a program do?',
                options: ['Repeat instructions', 'Delete files', 'Compile code', 'Design icons'],
                correctAnswer: 'Repeat instructions',
                explanation: 'Loops run the same block of code multiple times.',
              ),
              SeedQuestion(
                id: 'sample_cs_programming_core_q3',
                questionText: 'Which structure stores items in order by index?',
                options: ['List', 'Set only', 'Boolean', 'Function'],
                correctAnswer: 'List',
                explanation: 'A List stores ordered values that can be accessed by index.',
              ),
              SeedQuestion(
                id: 'sample_cs_programming_core_q4',
                questionText: 'What is a function mainly used for?',
                options: ['Reusable logic', 'Screen brightness', 'Network speed', 'File extension'],
                correctAnswer: 'Reusable logic',
                explanation: 'Functions package code so it can be called again.',
              ),
              SeedQuestion(
                id: 'sample_cs_programming_core_q5',
                questionText: 'Which value type represents true or false?',
                options: ['bool', 'String', 'double', 'List'],
                correctAnswer: 'bool',
                explanation: 'Boolean values hold either true or false.',
              ),
            ],
          ),
        ],
      ),
      SeedSubject(
        id: 'sample_cs_database',
        title: 'Databases',
        quizzes: [
          SeedQuiz(
            id: 'sample_cs_database_core',
            title: 'Database Essentials',
            duration: 10,
            questions: [
              SeedQuestion(
                id: 'sample_cs_database_core_q1',
                questionText: 'In Firestore, data is mainly organized into documents and what?',
                options: ['Collections', 'Tablespaces', 'Rows only', 'Pixels'],
                correctAnswer: 'Collections',
                explanation: 'Firestore stores documents inside collections.',
              ),
              SeedQuestion(
                id: 'sample_cs_database_core_q2',
                questionText: 'Which SQL command is used to read data?',
                options: ['SELECT', 'UPLOAD', 'PAINT', 'START'],
                correctAnswer: 'SELECT',
                explanation: 'SELECT retrieves rows from a database table.',
              ),
              SeedQuestion(
                id: 'sample_cs_database_core_q3',
                questionText: 'What does a primary key identify?',
                options: ['A unique record', 'A font family', 'A file size', 'A network cable'],
                correctAnswer: 'A unique record',
                explanation: 'A primary key uniquely identifies each record.',
              ),
              SeedQuestion(
                id: 'sample_cs_database_core_q4',
                questionText: 'Which operation adds new data?',
                options: ['Create', 'Ignore', 'Pause', 'Render'],
                correctAnswer: 'Create',
                explanation: 'CRUD starts with Create for adding new records.',
              ),
              SeedQuestion(
                id: 'sample_cs_database_core_q5',
                questionText: 'What is indexing used for?',
                options: ['Faster searching', 'Changing colors', 'Playing audio', 'Locking keyboard'],
                correctAnswer: 'Faster searching',
                explanation: 'Indexes help databases find matching records quickly.',
              ),
            ],
          ),
        ],
      ),
      SeedSubject(
        id: 'sample_cs_networking',
        title: 'Networking',
        quizzes: [
          SeedQuiz(
            id: 'sample_cs_networking_core',
            title: 'Networking Fundamentals',
            duration: 10,
            questions: [
              SeedQuestion(id: 'sample_cs_networking_core_q1', questionText: 'What does IP stand for?', options: ['Internet Protocol', 'Internal Program', 'Input Path', 'Image Process'], correctAnswer: 'Internet Protocol', explanation: 'IP is the addressing protocol used on the internet.'),
              SeedQuestion(id: 'sample_cs_networking_core_q2', questionText: 'Which device connects multiple networks together?', options: ['Router', 'Keyboard', 'Monitor', 'Scanner'], correctAnswer: 'Router', explanation: 'Routers forward packets between networks.'),
              SeedQuestion(id: 'sample_cs_networking_core_q3', questionText: 'HTTPS is mainly used to provide what?', options: ['Secure web communication', 'Image editing', 'Battery charging', 'Screen recording'], correctAnswer: 'Secure web communication', explanation: 'HTTPS encrypts browser-server communication.'),
              SeedQuestion(id: 'sample_cs_networking_core_q4', questionText: 'What does DNS translate?', options: ['Domain names to IP addresses', 'Photos to videos', 'Text to sound', 'Apps to icons'], correctAnswer: 'Domain names to IP addresses', explanation: 'DNS maps human-readable domains to numeric IP addresses.'),
              SeedQuestion(id: 'sample_cs_networking_core_q5', questionText: 'Which protocol is common for sending web pages?', options: ['HTTP', 'FTP only', 'SMTP only', 'POP3'], correctAnswer: 'HTTP', explanation: 'HTTP is the base protocol for web page requests and responses.'),
            ],
          ),
        ],
      ),
    ],
  ),
  SeedCourse(
    id: 'sample_math',
    title: 'Mathematics',
    description: 'Algebra, geometry, arithmetic, and problem solving.',
    subjects: [
      SeedSubject(
        id: 'sample_math_algebra',
        title: 'Algebra',
        quizzes: [
          SeedQuiz(
            id: 'sample_math_algebra_core',
            title: 'Algebra Practice',
            duration: 10,
            questions: [
              SeedQuestion(id: 'sample_math_algebra_core_q1', questionText: 'Solve: x + 7 = 12', options: ['5', '7', '12', '19'], correctAnswer: '5', explanation: 'Subtract 7 from both sides to get x = 5.'),
              SeedQuestion(id: 'sample_math_algebra_core_q2', questionText: 'What is 3x when x = 4?', options: ['12', '7', '9', '16'], correctAnswer: '12', explanation: '3 multiplied by 4 equals 12.'),
              SeedQuestion(id: 'sample_math_algebra_core_q3', questionText: 'Which expression means twice a number n?', options: ['2n', 'n + 2', 'n / 2', 'n - 2'], correctAnswer: '2n', explanation: 'Twice a number means 2 multiplied by that number.'),
              SeedQuestion(id: 'sample_math_algebra_core_q4', questionText: 'Simplify: 2a + 3a', options: ['5a', '6a', 'a5', '2a3a'], correctAnswer: '5a', explanation: 'Like terms can be added by combining coefficients.'),
              SeedQuestion(id: 'sample_math_algebra_core_q5', questionText: 'Solve: 2x = 18', options: ['9', '16', '20', '36'], correctAnswer: '9', explanation: 'Divide both sides by 2 to get x = 9.'),
            ],
          ),
        ],
      ),
      SeedSubject(
        id: 'sample_math_geometry',
        title: 'Geometry',
        quizzes: [
          SeedQuiz(
            id: 'sample_math_geometry_core',
            title: 'Geometry Basics',
            duration: 10,
            questions: [
              SeedQuestion(id: 'sample_math_geometry_core_q1', questionText: 'How many degrees are in a right angle?', options: ['90', '45', '180', '360'], correctAnswer: '90', explanation: 'A right angle is exactly 90 degrees.'),
              SeedQuestion(id: 'sample_math_geometry_core_q2', questionText: 'A triangle has how many sides?', options: ['3', '4', '5', '6'], correctAnswer: '3', explanation: 'A triangle is a polygon with three sides.'),
              SeedQuestion(id: 'sample_math_geometry_core_q3', questionText: 'Area of a rectangle equals length times what?', options: ['Width', 'Radius', 'Angle', 'Diameter'], correctAnswer: 'Width', explanation: 'Rectangle area is length multiplied by width.'),
              SeedQuestion(id: 'sample_math_geometry_core_q4', questionText: 'A circle boundary is called its what?', options: ['Circumference', 'Volume', 'Corner', 'Diagonal'], correctAnswer: 'Circumference', explanation: 'Circumference is the distance around a circle.'),
              SeedQuestion(id: 'sample_math_geometry_core_q5', questionText: 'How many parallel sides does a parallelogram have?', options: ['Two pairs', 'No sides', 'One side', 'Five pairs'], correctAnswer: 'Two pairs', explanation: 'Opposite sides of a parallelogram are parallel.'),
            ],
          ),
        ],
      ),
      SeedSubject(
        id: 'sample_math_arithmetic',
        title: 'Arithmetic',
        quizzes: [
          SeedQuiz(
            id: 'sample_math_arithmetic_core',
            title: 'Fast Arithmetic',
            duration: 8,
            questions: [
              SeedQuestion(id: 'sample_math_arithmetic_core_q1', questionText: 'What is 8 x 7?', options: ['56', '48', '64', '49'], correctAnswer: '56', explanation: '8 multiplied by 7 equals 56.'),
              SeedQuestion(id: 'sample_math_arithmetic_core_q2', questionText: 'What is 144 divided by 12?', options: ['12', '10', '14', '16'], correctAnswer: '12', explanation: '12 times 12 equals 144.'),
              SeedQuestion(id: 'sample_math_arithmetic_core_q3', questionText: 'What is 15% of 100?', options: ['15', '10', '20', '30'], correctAnswer: '15', explanation: '15 percent means 15 out of 100.'),
              SeedQuestion(id: 'sample_math_arithmetic_core_q4', questionText: 'What is 25 + 37?', options: ['62', '52', '72', '58'], correctAnswer: '62', explanation: '25 plus 37 equals 62.'),
              SeedQuestion(id: 'sample_math_arithmetic_core_q5', questionText: 'What is 90 - 46?', options: ['44', '54', '34', '40'], correctAnswer: '44', explanation: '90 minus 46 equals 44.'),
            ],
          ),
        ],
      ),
    ],
  ),
  SeedCourse(
    id: 'sample_science',
    title: 'Science',
    description: 'Physics, chemistry, biology, and everyday science.',
    subjects: [
      SeedSubject(
        id: 'sample_science_physics',
        title: 'Physics',
        quizzes: [
          SeedQuiz(id: 'sample_science_physics_core', title: 'Physics Quick Check', duration: 10, questions: [
            SeedQuestion(id: 'sample_science_physics_core_q1', questionText: 'What is the SI unit of force?', options: ['Newton', 'Joule', 'Watt', 'Volt'], correctAnswer: 'Newton', explanation: 'Force is measured in newtons.'),
            SeedQuestion(id: 'sample_science_physics_core_q2', questionText: 'Which quantity is speed with direction?', options: ['Velocity', 'Mass', 'Energy', 'Temperature'], correctAnswer: 'Velocity', explanation: 'Velocity is a vector quantity with magnitude and direction.'),
            SeedQuestion(id: 'sample_science_physics_core_q3', questionText: 'Gravity on Earth pulls objects toward what?', options: ['Earth center', 'The Moon', 'North pole only', 'The Sun only'], correctAnswer: 'Earth center', explanation: 'Gravity attracts objects toward Earth center.'),
            SeedQuestion(id: 'sample_science_physics_core_q4', questionText: 'Which device measures electric current?', options: ['Ammeter', 'Thermometer', 'Barometer', 'Compass'], correctAnswer: 'Ammeter', explanation: 'An ammeter measures current in amperes.'),
            SeedQuestion(id: 'sample_science_physics_core_q5', questionText: 'Light travels fastest in what?', options: ['Vacuum', 'Water', 'Glass', 'Air only'], correctAnswer: 'Vacuum', explanation: 'Light has its maximum speed in a vacuum.'),
          ]),
        ],
      ),
      SeedSubject(
        id: 'sample_science_chemistry',
        title: 'Chemistry',
        quizzes: [
          SeedQuiz(id: 'sample_science_chemistry_core', title: 'Chemistry Essentials', duration: 10, questions: [
            SeedQuestion(id: 'sample_science_chemistry_core_q1', questionText: 'What is the chemical symbol for water?', options: ['H2O', 'CO2', 'O2', 'NaCl'], correctAnswer: 'H2O', explanation: 'Water contains two hydrogen atoms and one oxygen atom.'),
            SeedQuestion(id: 'sample_science_chemistry_core_q2', questionText: 'A pH below 7 is usually what?', options: ['Acidic', 'Neutral', 'Basic', 'Metallic'], correctAnswer: 'Acidic', explanation: 'Acids have pH values below 7.'),
            SeedQuestion(id: 'sample_science_chemistry_core_q3', questionText: 'Which particle has a negative charge?', options: ['Electron', 'Proton', 'Neutron', 'Nucleus'], correctAnswer: 'Electron', explanation: 'Electrons carry negative electric charge.'),
            SeedQuestion(id: 'sample_science_chemistry_core_q4', questionText: 'NaCl is common table what?', options: ['Salt', 'Sugar', 'Water', 'Oxygen'], correctAnswer: 'Salt', explanation: 'Sodium chloride is table salt.'),
            SeedQuestion(id: 'sample_science_chemistry_core_q5', questionText: 'The periodic table organizes what?', options: ['Elements', 'Planets', 'Cells', 'Rocks only'], correctAnswer: 'Elements', explanation: 'The periodic table lists chemical elements.'),
          ]),
        ],
      ),
      SeedSubject(
        id: 'sample_science_biology',
        title: 'Biology',
        quizzes: [
          SeedQuiz(id: 'sample_science_biology_core', title: 'Biology Basics', duration: 10, questions: [
            SeedQuestion(id: 'sample_science_biology_core_q1', questionText: 'What is the basic unit of life?', options: ['Cell', 'Atom', 'Organ', 'Tissue only'], correctAnswer: 'Cell', explanation: 'Cells are the smallest living units.'),
            SeedQuestion(id: 'sample_science_biology_core_q2', questionText: 'Which organ pumps blood?', options: ['Heart', 'Lung', 'Brain', 'Kidney'], correctAnswer: 'Heart', explanation: 'The heart pumps blood through the body.'),
            SeedQuestion(id: 'sample_science_biology_core_q3', questionText: 'Plants make food using what process?', options: ['Photosynthesis', 'Respiration only', 'Digestion', 'Evaporation'], correctAnswer: 'Photosynthesis', explanation: 'Photosynthesis converts light energy into chemical energy.'),
            SeedQuestion(id: 'sample_science_biology_core_q4', questionText: 'DNA carries what?', options: ['Genetic information', 'Oxygen only', 'Heat', 'Water'], correctAnswer: 'Genetic information', explanation: 'DNA stores hereditary instructions.'),
            SeedQuestion(id: 'sample_science_biology_core_q5', questionText: 'Which blood cells help fight infection?', options: ['White blood cells', 'Red blood cells', 'Platelets only', 'Plasma only'], correctAnswer: 'White blood cells', explanation: 'White blood cells are part of the immune system.'),
          ]),
        ],
      ),
    ],
  ),
  SeedCourse(
    id: 'sample_english',
    title: 'English',
    description: 'Grammar, vocabulary, comprehension, and sentence skills.',
    subjects: [
      SeedSubject(
        id: 'sample_english_grammar',
        title: 'Grammar',
        quizzes: [
          SeedQuiz(id: 'sample_english_grammar_core', title: 'Grammar Builder', duration: 10, questions: [
            SeedQuestion(id: 'sample_english_grammar_core_q1', questionText: 'Which word is a noun?', options: ['Book', 'Quickly', 'Blue', 'Run'], correctAnswer: 'Book', explanation: 'A noun names a person, place, thing, or idea.'),
            SeedQuestion(id: 'sample_english_grammar_core_q2', questionText: 'Choose the correct sentence.', options: ['She is reading.', 'She are reading.', 'She am reading.', 'She be reading.'], correctAnswer: 'She is reading.', explanation: 'She takes the helping verb is.'),
            SeedQuestion(id: 'sample_english_grammar_core_q3', questionText: 'Which punctuation ends a question?', options: ['Question mark', 'Comma', 'Colon', 'Apostrophe'], correctAnswer: 'Question mark', explanation: 'Questions end with a question mark.'),
            SeedQuestion(id: 'sample_english_grammar_core_q4', questionText: 'Which word is an adjective?', options: ['Beautiful', 'Slowly', 'Jump', 'Table'], correctAnswer: 'Beautiful', explanation: 'An adjective describes a noun.'),
            SeedQuestion(id: 'sample_english_grammar_core_q5', questionText: 'What is the past tense of go?', options: ['Went', 'Goed', 'Going', 'Goes'], correctAnswer: 'Went', explanation: 'Went is the irregular past tense of go.'),
          ]),
        ],
      ),
      SeedSubject(
        id: 'sample_english_vocabulary',
        title: 'Vocabulary',
        quizzes: [
          SeedQuiz(id: 'sample_english_vocabulary_core', title: 'Vocabulary Boost', duration: 10, questions: [
            SeedQuestion(id: 'sample_english_vocabulary_core_q1', questionText: 'What does rapid mean?', options: ['Fast', 'Tiny', 'Silent', 'Heavy'], correctAnswer: 'Fast', explanation: 'Rapid means quick or fast.'),
            SeedQuestion(id: 'sample_english_vocabulary_core_q2', questionText: 'Which word means the opposite of ancient?', options: ['Modern', 'Old', 'Historic', 'Past'], correctAnswer: 'Modern', explanation: 'Modern means current or recent.'),
            SeedQuestion(id: 'sample_english_vocabulary_core_q3', questionText: 'A synonym for happy is what?', options: ['Joyful', 'Angry', 'Tired', 'Empty'], correctAnswer: 'Joyful', explanation: 'Joyful means full of happiness.'),
            SeedQuestion(id: 'sample_english_vocabulary_core_q4', questionText: 'What does fragile mean?', options: ['Easily broken', 'Very loud', 'Full of light', 'Hard to move'], correctAnswer: 'Easily broken', explanation: 'Fragile items can break easily.'),
            SeedQuestion(id: 'sample_english_vocabulary_core_q5', questionText: 'Which word means to improve?', options: ['Enhance', 'Reduce', 'Ignore', 'Damage'], correctAnswer: 'Enhance', explanation: 'Enhance means to make better.'),
          ]),
        ],
      ),
      SeedSubject(
        id: 'sample_english_comprehension',
        title: 'Comprehension',
        quizzes: [
          SeedQuiz(id: 'sample_english_comprehension_core', title: 'Reading Skills', duration: 10, questions: [
            SeedQuestion(id: 'sample_english_comprehension_core_q1', questionText: 'The main idea of a paragraph is its what?', options: ['Central point', 'Longest word', 'Last comma', 'Page number'], correctAnswer: 'Central point', explanation: 'The main idea is the central point or message.'),
            SeedQuestion(id: 'sample_english_comprehension_core_q2', questionText: 'A detail usually does what?', options: ['Supports the main idea', 'Changes the alphabet', 'Removes meaning', 'Ends the book'], correctAnswer: 'Supports the main idea', explanation: 'Details explain or support the main idea.'),
            SeedQuestion(id: 'sample_english_comprehension_core_q3', questionText: 'An inference is based on clues and what?', options: ['Reasoning', 'Guessing only', 'Fonts', 'Page color'], correctAnswer: 'Reasoning', explanation: 'Inference combines evidence with reasoning.'),
            SeedQuestion(id: 'sample_english_comprehension_core_q4', questionText: 'The author is the person who what?', options: ['Writes the text', 'Prints only the cover', 'Reads silently', 'Counts pages'], correctAnswer: 'Writes the text', explanation: 'An author writes the text.'),
            SeedQuestion(id: 'sample_english_comprehension_core_q5', questionText: 'Context clues help you understand what?', options: ['Unknown words', 'Battery level', 'Screen size', 'File format'], correctAnswer: 'Unknown words', explanation: 'Nearby words can reveal meaning.'),
          ]),
        ],
      ),
    ],
  ),
  SeedCourse(
    id: 'sample_gk',
    title: 'General Knowledge',
    description: 'World facts, Pakistan studies, geography, and current awareness.',
    subjects: [
      SeedSubject(
        id: 'sample_gk_world',
        title: 'World Facts',
        quizzes: [
          SeedQuiz(id: 'sample_gk_world_core', title: 'World Knowledge', duration: 10, questions: [
            SeedQuestion(id: 'sample_gk_world_core_q1', questionText: 'Which is the largest ocean?', options: ['Pacific Ocean', 'Atlantic Ocean', 'Indian Ocean', 'Arctic Ocean'], correctAnswer: 'Pacific Ocean', explanation: 'The Pacific Ocean is the largest ocean on Earth.'),
            SeedQuestion(id: 'sample_gk_world_core_q2', questionText: 'How many continents are commonly counted?', options: ['7', '5', '8', '10'], correctAnswer: '7', explanation: 'The common model has seven continents.'),
            SeedQuestion(id: 'sample_gk_world_core_q3', questionText: 'Which planet is known as the Red Planet?', options: ['Mars', 'Venus', 'Jupiter', 'Mercury'], correctAnswer: 'Mars', explanation: 'Mars appears reddish due to iron oxide on its surface.'),
            SeedQuestion(id: 'sample_gk_world_core_q4', questionText: 'Which is the tallest mountain above sea level?', options: ['Mount Everest', 'K2', 'Nanga Parbat', 'Kilimanjaro'], correctAnswer: 'Mount Everest', explanation: 'Mount Everest is the tallest mountain above sea level.'),
            SeedQuestion(id: 'sample_gk_world_core_q5', questionText: 'Which language has the most native speakers?', options: ['Mandarin Chinese', 'English', 'Arabic', 'French'], correctAnswer: 'Mandarin Chinese', explanation: 'Mandarin Chinese has the largest native-speaker population.'),
          ]),
        ],
      ),
      SeedSubject(
        id: 'sample_gk_pakistan',
        title: 'Pakistan Studies',
        quizzes: [
          SeedQuiz(id: 'sample_gk_pakistan_core', title: 'Pakistan Basics', duration: 10, questions: [
            SeedQuestion(id: 'sample_gk_pakistan_core_q1', questionText: 'What is the capital of Pakistan?', options: ['Islamabad', 'Karachi', 'Lahore', 'Peshawar'], correctAnswer: 'Islamabad', explanation: 'Islamabad is the capital city of Pakistan.'),
            SeedQuestion(id: 'sample_gk_pakistan_core_q2', questionText: 'Which city is known as the City of Lights in Pakistan?', options: ['Karachi', 'Multan', 'Quetta', 'Sialkot'], correctAnswer: 'Karachi', explanation: 'Karachi is often called the City of Lights.'),
            SeedQuestion(id: 'sample_gk_pakistan_core_q3', questionText: 'Which mountain is Pakistan famous for as the second highest in the world?', options: ['K2', 'Everest', 'Fuji', 'Denali'], correctAnswer: 'K2', explanation: 'K2 is the second highest mountain in the world.'),
            SeedQuestion(id: 'sample_gk_pakistan_core_q4', questionText: 'Pakistan gained independence in which year?', options: ['1947', '1956', '1965', '1971'], correctAnswer: '1947', explanation: 'Pakistan became independent in 1947.'),
            SeedQuestion(id: 'sample_gk_pakistan_core_q5', questionText: 'Which sea borders southern Pakistan?', options: ['Arabian Sea', 'Red Sea', 'Caspian Sea', 'Black Sea'], correctAnswer: 'Arabian Sea', explanation: 'The Arabian Sea lies south of Pakistan.'),
          ]),
        ],
      ),
      SeedSubject(
        id: 'sample_gk_geography',
        title: 'Geography',
        quizzes: [
          SeedQuiz(id: 'sample_gk_geography_core', title: 'Geography Starter', duration: 10, questions: [
            SeedQuestion(id: 'sample_gk_geography_core_q1', questionText: 'A map key explains what?', options: ['Symbols on a map', 'Only weather', 'Phone signals', 'Book titles'], correctAnswer: 'Symbols on a map', explanation: 'A map key or legend explains map symbols.'),
            SeedQuestion(id: 'sample_gk_geography_core_q2', questionText: 'The equator divides Earth into which hemispheres?', options: ['Northern and Southern', 'Eastern and Western', 'Land and Water', 'Hot and Cold'], correctAnswer: 'Northern and Southern', explanation: 'The equator separates northern and southern hemispheres.'),
            SeedQuestion(id: 'sample_gk_geography_core_q3', questionText: 'Which line measures distance north or south of the equator?', options: ['Latitude', 'Longitude', 'Altitude', 'Compass'], correctAnswer: 'Latitude', explanation: 'Latitude lines run east-west and measure north-south position.'),
            SeedQuestion(id: 'sample_gk_geography_core_q4', questionText: 'A desert is usually very what?', options: ['Dry', 'Wet', 'Crowded with trees', 'Frozen always'], correctAnswer: 'Dry', explanation: 'Deserts receive very little precipitation.'),
            SeedQuestion(id: 'sample_gk_geography_core_q5', questionText: 'Which is a renewable natural resource?', options: ['Sunlight', 'Coal', 'Petroleum', 'Natural gas'], correctAnswer: 'Sunlight', explanation: 'Sunlight is naturally replenished every day.'),
          ]),
        ],
      ),
    ],
  ),
];
