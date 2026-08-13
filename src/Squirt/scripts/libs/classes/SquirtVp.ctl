

#uses "oaGuiTest"

class SquirtVp
{

  public SquirtVp(const string &vpId, const vector<shape> &shapes)
  {
    this.id = vpId;
    this.shapes = shapes;
  }

  public int init()
  {

    if (this.id.isEmpty())
      throw(makeError("", PRIO_WARNING, ERR_CONTROL, 54, "The VP ID can not be empty".subst()));

    if (shapes.count() <= 0)
      throw(makeError("", PRIO_WARNING, ERR_CONTROL, 54, "The are no shapes defined for VP $1".subst(this.id)));

    JsonFile metaFile = this.getMetaFile();

    if (!metaFile.exists())
    {
      const string fullVpPath = PROJ_PATH + DATA_REL_PATH + this.getMetaRelPath();
      throwError(makeError("", PRIO_INFO, ERR_CONTROL, 0, "The VP $1 does not exists, this will be created under $2".subst(this.id, fullVpPath)));
      mkdir(dirName(fullVpPath));
      metaFile.setPath(fullVpPath);
      metaFile.create();
      mapping map;

      for (int i = 0; i < shapes.count(); i++)
      {
        const shape sh = shapes.at(i);
        map[getNamePathOfShape(sh)] = guiTestGetCurrentAttributes(sh);
      }

      content = makeMapping("id", this.id, "shapes", map);
      metaFile.write(content);
      return 0;
    }


    content.clear();
    metaFile.read(content);

    if (!content.contains("id") || !content.contains("shapes"))
    {
      throw (makeError("", PRIO_WARNING, ERR_CONTROL, 54, "The VP $1 is not valid, it does not contain the required attributes".subst(this.id)));
      return -1;
    }

    if (content.value("id") != this.id)
    {
      throw (makeError("", PRIO_WARNING, ERR_CONTROL, 54, "The VP $1 is not valid, it does not contain the correct ID".subst(this.id)));
      return -1;
    }

    return 0;
  }

  public string getMetaPath()
  {
    return getPath(DATA_REL_PATH, getMetaRelPath());
  }

  public mapping getShapesAndAttributes()
  {
    return content.value("shapes");
  }

  protected JsonFile getMetaFile()
  {
    JsonFile vpFile = JsonFile(this.getMetaPath());
    return vpFile;
  }


  mapping content;
  protected string id;
  protected vector<shape> shapes;


  protected string getMetaRelPath()
  {
    return "splash/VPs/" + this.id + ".json";
  }
};
