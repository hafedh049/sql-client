import os
import json
from flask import Flask, request, jsonify
import uuid

# str(uuid.uuid4())
dataFile = "data.json"

# create data files if not exist
if not os.path.isfile(dataFile):
    with open(dataFile, mode="a", newline="") as file:
        file.writelines('{"users" : {}, "totalQuerys" : 1}')


# load data file
def loadJsonData(file):
    with open(file, "r") as f:
        return json.load(f)


# edit data file
def SaveJsonData(
    file,
    key,
    value,
    subclass=None,
    subclass2=None,
    subclass3=None,
    subclass4=None,
    addOrAppend="Append",
):
    with open(file, "r") as f:
        data = json.load(f)
    if subclass is None:
        data[key] = value
    else:
        if subclass2 is None:
            if addOrAppend == "Append":
                data[key][subclass].append(value)
            else:
                data[key][subclass] = value
        else:
            if subclass3 is None:
                if addOrAppend == "Append":
                    data[key][subclass][subclass2].append(value)
                else:
                    data[key][subclass][subclass2] = value
            else:
                if subclass4 is None:
                    if addOrAppend == "Append":
                        data[key][subclass][subclass2][subclass3].append(value)
                    else:
                        data[key][subclass][subclass2][subclass3] = value
                else:
                    if addOrAppend == "Append":
                        data[key][subclass][subclass2][subclass3][subclass4].append(
                            value
                        )
                    else:
                        data[key][subclass][subclass2][subclass3][subclass4] = {}
                        data[key][subclass][subclass2][subclass3][subclass4] = value
    with open(file, "w") as f:
        json.dump(data, f)


def deleteFromJsonFile(file, key):
    with open(file, "r", encoding="utf-8") as f:
        data = json.load(f)
    del data["users"][key]
    with open(file, "w", encoding="utf-8") as f:
        json.dump(data, f)


def userExist(username: str, password: str) -> bool:
    data = loadJsonData(dataFile)["users"]
    if username in list(data.keys()):
        if password == data[username]["password"]:
            return True, data[username]
        else:
            return False, "Wrong Password"
    else:
        return False, "User Not Exist"


def createUser(username: str, password: str) -> bool:
    data = loadJsonData(dataFile)["users"]
    if username not in list(data.keys()):
        uid = str(uuid.uuid4())
        value = {
            "id": uid,
            "password": password,
            "querys": {},
            "queryWithDate": "",
            "authorized": True,
        }
        SaveJsonData(
            dataFile,
            "users",
            value,
            subclass=username,
            subclass2=None,
            subclass3=None,
            subclass4=None,
            addOrAppend="add",
        )
        return True, uid
    else:
        return False, "User Already Exist"


def returnTotalQuerys() -> int:
    TotalQuerys = loadJsonData(dataFile)["totalQuerys"]
    return TotalQuerys


def setTotalQuerys(newValue: int) -> int:
    SaveJsonData(
        dataFile,
        "totalQuerys",
        newValue,
        subclass=None,
        subclass2=None,
        subclass3=None,
        subclass4=None,
        addOrAppend="add",
    )
    TotalQuerys = loadJsonData(dataFile)["totalQuerys"]
    return TotalQuerys


def returnUserQuerys(username: str) -> dict:
    data = loadJsonData(dataFile)["users"]
    if username in list(data.keys()):
        Querys = data[username]["querys"]
        return True, Querys
    else:
        return False, "User Not Exist"


def updateOrAddQuery(username: str, querys: dict) -> bool:
    data = loadJsonData(dataFile)["users"]
    if username in list(data.keys()):
        SaveJsonData(
            dataFile,
            "users",
            querys,
            subclass=username,
            subclass2="querys",
            subclass3=None,
            subclass4=None,
            addOrAppend="add",
        )
        return returnUserQuerys(username)
    else:
        return False, "User Not Exist"


def updateQueryWithTime(username: str, newValue: str) -> bool:
    data = loadJsonData(dataFile)["users"]
    if username in list(data.keys()):
        SaveJsonData(
            dataFile,
            "users",
            newValue,
            subclass=username,
            subclass2="queryWithDate",
            subclass3=None,
            subclass4=None,
            addOrAppend="add",
        )
        return True, newValue
    else:
        return False, "User Not Exist"


def returnQueryWithTime(username: str) -> bool:
    data = loadJsonData(dataFile)["users"]
    if username in list(data.keys()):
        return True, data[username]["queryWithDate"]
    else:
        return False, "User Not Exist"


app = Flask(__name__)


@app.route("/")
def index():
    return "200OK", 200


# %FROM% %TO%
# %F% %T%


@app.route("/totalQuerys", methods=["GET", "POST"])
def totalQuerys():
    if request.method == "POST":
        user_data = request.json
        keys = list(user_data.keys())
        if "totalQuerys" in keys:
            newTotalQuerys = user_data["totalQuerys"]
            result = {"status": True, "totalQuerys": setTotalQuerys(newTotalQuerys)}
            return jsonify(result), 200
    else:
        totalQuerys = returnTotalQuerys()
        result = {"status": True, "totalQuerys": totalQuerys}
        return jsonify(result), 200


@app.route("/login", methods=["POST"])
def login():
    user_data = request.json
    print(user_data)
    keys = list(user_data.keys())
    if "username" in keys and "password" in keys:
        username = user_data["username"]
        password = user_data["password"]
        userResponce, userID = userExist(username, password)
        # print(f'{username} - {password}')
        if userResponce == True:
            result = {"status": userResponce, "data": userID}
            return jsonify(result), 200
        else:
            result = {"status": userResponce, "message": userID}
            return jsonify(result), 202
    else:
        result = {"status": False, "message": "username or password is missing"}
        return jsonify(result), 202


@app.route("/createUser", methods=["POST"])
def createUserWeb():
    user_data = request.json
    keys = list(user_data.keys())
    if "username" in keys and "password" in keys:
        username = user_data["username"]
        password = user_data["password"]
        userResponce, userID = createUser(username, password)
        # print(f'{username} - {password}')
        if userResponce == True:
            result = {"status": userResponce, "id": userID}
            return jsonify(result), 200
        else:
            result = {"status": userResponce, "message": userID}
            return jsonify(result), 202
    else:
        result = {"status": False, "message": "username or password is missing"}
        return jsonify(result), 202


@app.route("/getUserQuerys", methods=["GET"])
def getUserQuerys():
    user_data = request.json
    keys = list(user_data.keys())
    if "username" in keys:
        username = user_data["username"]
        userResponce, Querys = returnUserQuerys(username)
        if userResponce == True:
            result = {"status": userResponce, "Querys": Querys}
            return jsonify(result), 200
        else:
            result = {"status": userResponce, "message": Querys}
            return jsonify(result), 202
    else:
        result = {"status": False, "message": "username is missing"}
        return jsonify(result), 202


@app.route("/addOrUpdateUserQuerys", methods=["POST"])
def addOrUpdateUserQuerys():
    user_data = request.json
    keys = list(user_data.keys())
    if "username" in keys and "querys" in keys:
        username = user_data["username"]
        querys = user_data["querys"]
        userResponce, Querys = updateOrAddQuery(username, querys)
        if userResponce == True:
            result = {"status": userResponce}
            return jsonify(result), 200
        else:
            result = {"status": userResponce}
            return jsonify(result), 202
    else:
        result = {"status": False, "message": "username or querys is missing"}
        return jsonify(result), 202


@app.route("/queryWithTime", methods=["GET", "POST"])
def queryWithTime():
    user_data = request.json
    keys = list(user_data.keys())
    if request.method == "POST":
        if "username" in keys and "newValue" in keys:
            username = user_data["username"]
            newValue = user_data["newValue"]
            userResponce, Query = updateQueryWithTime(username, newValue)
            if userResponce == True:
                result = {"status": userResponce, "Querys": Query}
                return jsonify(result), 200
            else:
                result = {"status": userResponce, "message": Query}
                return jsonify(result), 202
        else:
            result = {"status": False, "message": "username or newValue is missing"}
            return jsonify(result), 202
    else:
        if "username" in keys:
            username = user_data["username"]
            userResponce, Query = returnQueryWithTime(username)
            if userResponce == True:
                result = {"status": userResponce, "Querys": Query}
                return jsonify(result), 200
            else:
                result = {"status": userResponce, "message": Query}
                return jsonify(result), 202
        else:
            result = {"status": False, "message": "username is missing"}
            return jsonify(result), 202


@app.route("/getUsersList", methods=["GET"])
def getUsersList():
    users = loadJsonData(dataFile)["users"]
    result = {"status": True, "users": users}
    return jsonify(result), 200


@app.route("/getUserData", methods=["GET"])
def getUserData():
    user_data = request.json
    keys = list(user_data.keys())
    users = loadJsonData(dataFile)["users"]
    if "username" in keys:
        if user_data["username"] in list(users.keys()):
            result = {"status": True, "data": users[user_data["username"]]}
            return jsonify(result), 200
        else:
            result = {"status": False, "message": "user not exist"}
            return jsonify(result), 202
    else:
        result = {"status": False, "message": "username is missing"}
        return jsonify(result), 202


@app.route("/authorization", methods=["POST"])
def authorization():
    user_data = request.json
    keys = list(user_data.keys())
    users = loadJsonData(dataFile)["users"]
    if "username" in keys:
        if user_data["username"] in list(users.keys()):
            if users[user_data["username"]]["authorized"]:
                SaveJsonData(
                    dataFile,
                    "users",
                    False,
                    subclass=user_data["username"],
                    subclass2="authorized",
                    subclass3=None,
                    subclass4=None,
                    addOrAppend="add",
                )
            else:
                SaveJsonData(
                    dataFile,
                    "users",
                    True,
                    subclass=user_data["username"],
                    subclass2="authorized",
                    subclass3=None,
                    subclass4=None,
                    addOrAppend="add",
                )
            users = loadJsonData(dataFile)["users"]
            result = {"status": True, "data": users[user_data["username"]]}
            return jsonify(result), 200
        else:
            result = {"status": False, "message": "user not exist"}
            return jsonify(result), 202
    else:
        result = {"status": False, "message": "username is missing"}
        return jsonify(result), 202


@app.route("/removeUser", methods=["POST"])
def removeUser():
    user_data = request.json
    keys = list(user_data.keys())
    users = loadJsonData(dataFile)["users"]
    if "username" in keys:
        if user_data["username"] in list(users.keys()):
            deleteFromJsonFile(dataFile, user_data["username"])
            result = {"status": True}
            return jsonify(result), 200
        else:
            result = {"status": False, "message": "user not exist"}
            return jsonify(result), 202
    else:
        result = {"status": False, "message": "username is missing"}
        return jsonify(result), 202


app.run(host="0.0.0.0", port=4444, debug=True)
