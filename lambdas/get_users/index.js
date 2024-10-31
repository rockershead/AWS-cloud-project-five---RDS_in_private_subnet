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

async function listAllUsers() {
  try {
    const users = await User.findAll({
      attributes: ["name", "age", "hobby"],
    });

    const result = users.map((user) => user.dataValues);

    return {
      statusCode: 200,
      body: JSON.stringify(result),
    };
  } catch (error) {
    console.error("Error fetching users:", error);

    return {
      statusCode: 500,
      body: JSON.stringify({
        message: "Error fetching users",
        error: error.message,
      }),
    };
  }
}

async function queryUsers(queryStringParams) {
  try {
    const users = await User.findAll({
      where: queryStringParams,
      attributes: ["name", "age", "hobby"],
    });

    const result = users.map((user) => user.dataValues);

    return {
      statusCode: 200,
      body: JSON.stringify(result),
    };
  } catch (error) {
    console.error("Error fetching users:", error);

    return {
      statusCode: 500,
      body: JSON.stringify({
        message: "Error fetching users",
        error: error.message,
      }),
    };
  }
}

exports.handler = async (event) => {
  console.log(event);
  if (event.queryStringParameters != null) {
    const res = await queryUsers(event.queryStringParameters);
    return res;
  } else {
    //get all users
    const res = await listAllUsers();
    return res;
  }
};
