const { Sequelize } = require("sequelize");
const UserModel = require("./models/User");

const databaseName = process.env.DATABASE_NAME;
const username = process.env.DB_USERNAME;
const password = process.env.DB_PASSWORD;
const host = process.env.DB_HOST;
const port = process.env.DB_PORT;

const sequelize = new Sequelize(databaseName, username, password, {
  host: host,
  dialect: "mysql",
  port: port,
});

const User = UserModel(sequelize);

async function createUser(name, hobby, age) {
  try {
    // Synchronize the model with the database (create table if it doesn't exist)
    await sequelize.sync();

    // Create a new user record in the database
    const newUser = await User.create({
      name: name,
      hobby: hobby,
      age: age,
    });

    console.log("New user added:", newUser.toJSON());

    return {
      statusCode: 200,
      body: JSON.stringify({ message: "New user added successfully!" }),
    };
  } catch (error) {
    console.error("Error inserting user:", error);

    return {
      statusCode: 500,
      body: JSON.stringify({
        message: "Error inserting user",
        error: error.message,
      }),
    };
  }
}

exports.handler = async (event) => {
  const body = JSON.parse(event.body);
  const { name, hobby, age } = body;

  const res = await createUser(name, hobby, age);
  return res;
};
