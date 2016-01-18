package com.controller;

import com.QueryToSend;
import com.clientTCP.ClientTCP;
import org.slf4j.Logger;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.ui.ModelMap;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseBody;

import javax.management.Query;
import javax.servlet.http.HttpServletRequest;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.CopyOnWriteArrayList;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.atomic.AtomicInteger;


@Controller
@RequestMapping("/")
public class DatabaseOperationsController {

    List<String> results = new CopyOnWriteArrayList<>();
    AtomicInteger counter;
    private ExecutorService executorService = Executors.newFixedThreadPool(100);
//    private static final Logger LOGGER = Logger.getLogger(DatabaseOperationsController.class);

    @RequestMapping(method = RequestMethod.GET)
    public String sayHello(ModelMap model) {
        return "index";
    }


    @RequestMapping(value = "/operations/", method = RequestMethod.POST)
    @ResponseBody
    public String operations(@RequestBody List<QueryToSend> queries) {
        results = new CopyOnWriteArrayList<>();
        AtomicInteger counter2 = new AtomicInteger(0);
        counter = new AtomicInteger(0);
        for (QueryToSend query : queries) {
            for (int i = 0; i < query.getTimes(); i++) {
                invokeOperation(counter2.getAndIncrement(), "1" + query.getCommand());

            }
        }

        return "Ok";
    }

    @RequestMapping(value = "/operations/check/", method = RequestMethod.GET, headers = "Accept=application/json")
    @ResponseBody
    public String check() {

        return arrayToString(results);
    }

    private void invokeOperation(int number, final String operation) {
        try {
            ClientTCP clientTCP = new ClientTCP();

        CompletableFuture.supplyAsync(() -> clientTCP.sendMessage(operation), executorService).thenAccept((a) -> {
            //if (a.toString().startsWith("{updated"))
            results.add(Integer.toString(number) + " ::: " + operation + " ::: " + a.toString());
            System.out.println(counter.getAndIncrement() + " : " + operation + " : " + a.toString());
        });
        } catch (IOException e) {
        results.add(Integer.toString(number) + " ::: " + operation + " ::: " + "error: no connection");
    }

    }

    private String arrayToString(List<String> list) {
        String result = "[";
        for (String elem : list) {
            result += "\"" + elem.replace("\\\"", "\"").replaceAll("\"", "\\\\\"") + "\",";
        }
        result = result.substring(0, result.length() - 1);
        result += "]";
        return result;
    }

//    private String makeQuery(QueryToSend query){
//
//        //if(query.getType().equals("insert")){
//            String generateValues = "";
//            for(String que : query.getValues()){
//                generateValues += "'"+ que +"',";
//            }
//            generateValues = generateValues.substring(0, generateValues.length()-1);
//            return "1insert into " + query.getTableName() + " values("+ generateValues + ")";
//
//    }


}
