package com.clientTCP;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.io.OutputStreamWriter;
import java.io.PrintWriter;
import java.net.Socket;
import java.net.UnknownHostException;
import java.util.Scanner;

public class ClientTCP {

    Socket socket;
    PrintWriter writer;
    BufferedReader reader;

    public ClientTCP() throws IOException {

            socket = new Socket("localhost", 6887);
            writer =  new PrintWriter(new OutputStreamWriter(socket.getOutputStream(), "UTF-8"));
            reader = new BufferedReader(new InputStreamReader(socket.getInputStream(), "UTF-8"));


    }



    public String sendMessage(String message) {
        String result = "";

        try {
            writer.print(message);
            writer.flush();

            result += reader.readLine();
            while (reader.ready()){

                result += reader.readLine();
            }
            try {
                Thread.sleep(300);
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
            writer.print("2SELECT NEW()");
            writer.flush();
            closeConnection();
            return result.toString();
        } catch (IOException e) {
            return "blad" + e.getMessage();
        }

    }

    public void closeConnection() {
        try {
            socket.close();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }


}