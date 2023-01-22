package labyrinthe.core.objets;

public abstract class Objet 
{
    private static int count = 1;
    private final int id;
    public String nom;

    public Objet()
    {
        this.id = count++;
        this.nom = "Guide de survie de l'étudiant en BUT"; // très utile pour la première année ^^
    }

    public Objet(String nom)
    {
        this.id = count++;
        this.nom = nom;
    }

    //get id
    public int getId()
    {
        return this.id;
    }

    // set/get Nom
    public void setNom(String nom)
    {
        this.nom = nom;
    }

    public String getNom()
    {
        return this.nom;
    }

    @Override
    public String toString()
    {
        return "id: " + this.id + ", nom: " + nom;
    }

    @Override
    public boolean equals(Object o)
    {
        if (o instanceof Objet == false)
            return false;
        else
        {
            Objet caseCoude = (Objet) o;
            return this.toString().equals(caseCoude.toString());
        }
    }
}
