const { Sequelize, DataTypes } = require("sequelize");

// Export a function that defines the model and returns it
module.exports = (sequelize) => {
  const User = sequelize.define(
    "User",
    {
      // Define the columns
      name: {
        type: DataTypes.STRING,
        allowNull: false,
      },
      hobby: {
        type: DataTypes.STRING,
      },
      age: {
        type: DataTypes.INTEGER,
      },
    },
    {
      tableName: "user",
      timestamps: false,
    }
  );

  return User;
};
