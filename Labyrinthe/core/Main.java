package labyrinthe.core;
import labyrinthe.core.objets.*;

// import mg2d.*;
// Nous sommes désolé monsieur mais non n'utiliseront pas MG2D (ni MG3D) :'(
    import java.util.ArrayList;
    import java.util.concurrent.ThreadLocalRandom;

import java.util.Scanner;
    
    public class Main 
    {
        public static void main(String[] args)
        {
            Scanner scanner = new Scanner(System.in);

            ArrayList<Objet> listeObjet = new ArrayList<Objet>();
            Heaume heaume = new Heaume();
            listeObjet.add(heaume);
            Chandelier chandelier = new Chandelier();
            listeObjet.add(chandelier);
            Epee epee = new Epee();
            listeObjet.add(epee);
            Emeraude emeraude = new Emeraude();
            listeObjet.add(emeraude);

            ArrayList<Joueur> listeJoueurs = new ArrayList<>();
            System.out.println("Entrez le nom du joueur : ");
            while (scanner.hasNext())
            {
                String nom = scanner.next();
                if (nom.equals("fin"))
                    break;
                else
                {
                    Joueur j = new Joueur(nom, null);
                    listeJoueurs.add(j);
                    System.out.println("Entrez le nom du joueur : ");  
                }
            }
            /*while (!finAjoutJoueur)
            {
                System.out.println("Entrez le nom du joueur");
                String nom = scanner.nextLine();
                if (nom == "fin")
                    finAjoutJoueur = true;
                else
                {
                    Joueur j = new Joueur(nom, null);
                    listeJoueurs.add(j);
                }
            }*/

            ArrayList<Objet> listeToutObjet = new ArrayList<Objet>(listeObjet);
            for (int i = 0; i < listeJoueurs.size(); i++)
            {
                int randomObjet = ThreadLocalRandom.current().nextInt(0,listeToutObjet.size());
                listeJoueurs.get(i).addObjet(listeToutObjet.get(randomObjet));
                listeToutObjet.remove(randomObjet);
            }
            
            Plateau plateau = new Plateau(listeJoueurs);

            while (!plateau.finPartie())
            {
                for (int i = 0; i < listeJoueurs.size(); i++)
                {
                    var caseDefaussee = plateau.getCaseDefaussee();
            
                    System.out.println(listeJoueurs.get(i));
                    System.out.println(plateau);
                    System.out.println(caseDefaussee);

                    System.out.println("Entrez rotation, x, y");
                    int rotation = scanner.nextInt();
                    int x = scanner.nextInt();
                    int y = scanner.nextInt();

                    caseDefaussee.setRotation(rotation);
                    caseDefaussee.setPosition(new Position(x,y));
                    plateau.deplacerCase(caseDefaussee);

                    System.out.println(plateau);

                    System.out.println(listeJoueurs.get(i).getToutDeplacementPossible(plateau.getPlateau()));
                    
                    System.out.println("Entrez x, y");
                    x = scanner.nextInt();
                    y = scanner.nextInt();

                    listeJoueurs.get(i).deplacer(plateau.getPlateau(), new Position(x,y));

                    plateau.joueurRecupereObjet(listeJoueurs.get(i));
                    
                    if (listeJoueurs.get(i).recupererToutObjet())
                        System.out.println(listeJoueurs.get(i).getNom() + " à gagné !");                    
                }
            }

            scanner.close();
        }  
    }
