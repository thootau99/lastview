import java.util.Scanner;
import java.lang.Math;
public class test {
    public static void main(String[] args){
        Scanner in = new Scanner(System.in);

        double height = in.nextInt();
        double width = in.nextInt();
        double result = 0;
        height = height / 100;
        result = width / Math.pow(height, 2);
        System.out.println(Math.floor(result*10)/10);
    }
}
