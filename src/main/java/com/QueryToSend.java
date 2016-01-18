package com;

import java.util.ArrayList;
import java.util.List;

/**
 * Created by piotrek on 17.01.16.
 */
public class QueryToSend {
    private String type;
    private String tableName;
    private List<String> values = new ArrayList<String>();
    private int times;
    private String command;

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public String getTableName() {
        return tableName;
    }

    public void setTableName(String tableName) {
        this.tableName = tableName;
    }

    public List<String> getValues() {
        return values;
    }

    public void setValues(List<String> values) {
        this.values = values;
    }

    public int getTimes() {
        return times;
    }

    public void setTimes(int times) {
        this.times = times;
    }

    public void setCommand(String commmand) {
        this.command = commmand;
    }

    public String getCommand() {
        return command;
    }
}
