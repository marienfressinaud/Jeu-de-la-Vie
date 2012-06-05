using SDL;

/*
 * Le monde est l'endroit dans lequel vivent et se développent les cellules
 */
public class Monde
{
	/* Taille du monde, calculée en fonction de la taille des cellules */
	protected int16 largeur;
	protected int16 hauteur;
	
	/* Les habitants du monde (les cellules donc) */
	protected Cellule[ , ] habitants;
	
	/* La taille des habitants */
	public uint16 _taille_habitants;
	public uint16 taille_habitants {
		get {
			return _taille_habitants;
		}
		set {
			if (value > 200) {
				value = 200;
			} else if (value < 1) {
				value = 1;
			}
			
			_taille_habitants = value;
		}
	}
	
	/*
	 * Constructeur
	 * @param largeur, hauteur la taille du monde
	 *      > Attention, il s'agit de la taille réelle !
	 *      > Non calculée à partir de la taille des cellules
	 * @param taille_habitants la taille des habitants
	 */
	public Monde (int16 largeur, int16 hauteur, uint16 taille_habitants) {
		this.taille_habitants = taille_habitants;
		
		this.largeur = largeur / (int16)this.taille_habitants;
		this.hauteur = hauteur / (int16)this.taille_habitants;
		
		this.habitants = new Cellule[this.largeur, this.hauteur];
	}
	
	/*
	 * Fait avancer le monde d'une étape
	 * Les états de toutes les cellules sont recalculées
	 */
	public void avancerEtape () {
		for (int i = 0; i < largeur; i++) {
			for (int j = 0; j < hauteur; j++) {
				calculerEtat (i, j);
			}
		}
		
		foreach (Cellule c in habitants) {
			c.validerEtat ();
		}
	}
	
	/*
	 * Calcule l'état d'une cellule en mettant à jour son nombre de voisines
	 * @param x, y la position de la cellule dans le monde
	 */
	protected void calculerEtat (int x, int y) {
		int nb_voisines = 0;
		
		for (int i = x - 1 ; i <= x + 1; i++) {
			for (int j = y - 1 ; j <= y + 1; j++) {
				if ( i >= 0 && i < largeur
				 && j >= 0 && j < hauteur
				 && !(i == x && j == y)
				 && habitants[i, j].etat == Etat.VIVANTE) {
				 	nb_voisines++;
				}
			}
		}
		
		habitants[x, y].nb_voisines = nb_voisines;
	}
	
	/*
	 * Met à jour l'état de la cellule spécifiée
	 * @param x, y la position de la cellule dans le monde
	 * @param etat le nouvel état de la cellule
	 */
	public void changerEtatCellule (int x, int y, Etat etat) {
		if (x >= 0 && x < largeur
		 && y >= 0 && y < hauteur) {
		 	switch (etat) {
			case Etat.VIVANTE:
				habitants[x, y].insufflerVie ();
				break;
			case Etat.INEXISTANTE:
				habitants[x, y].annihiler ();
				break;
			case Etat.MORTE:
				habitants[x, y].tuer ();
				break;
			default:
				break;
			}
		}
	}
	
	/*
	 * Peuple le monde en rajoutant aléatoirement des cellules
	 */
	public void peupler () {
		Rand random = new Rand ();
		int nb_aleatoire;
		
		foreach (Cellule c in habitants) {
			// le facteur de création des cellules est de 1/15
			nb_aleatoire = random.int_range (0, 15);
			if (nb_aleatoire == 0) {
				c.insufflerVie ();
			}
		}
	}
	
	/*
	 * Détruit le monde en exterminant les cellules vivantes
	 * et en nettoyant les débris cellulaires
	 */
	public void annihilerLePeuple () {
		foreach (Cellule c in habitants) {
			c.annihiler ();
		}
	}
	
	/*
	 * Tue toutes les cellules vivantes
	 */
	public void tuerLePeuple () {
		foreach (Cellule c in habitants) {
			c.tuer ();
		}
	}
}

/*
 * Le monde graphique est la représentation du monde à l'écran (SDL)
 */
public class MondeGraphique : Monde
{
	/* L'écran sur lequel se déroule le jeu */
	public weak Screen ecran;
	
	/*
	 * Constructeur
	 * @param largeur, hauteur la taille du monde
	 *      > Attention, il s'agit de la taille réelle !
	 *      > Non calculée à partir de la taille des cellules
	 * @param taille_habitants la taille des habitants
	 * @param ecran l'écran sur lequel se déroule le jeu
	 */
	public MondeGraphique (int16 largeur, int16 hauteur,
	                       uint16 taille_habitants, SDL.Screen ecran) {
		base (largeur, hauteur, taille_habitants);
		this.ecran = ecran;
		
		// TODO À revoir ?
		// Cellules créées ici car il faut des cellules graphiques
		// > et je ne souhaite pas rendre dépendante la classe Monde
		// > à la classe CelluleGraphique
		for (int i = 0; i < this.largeur; i++) {
			for (int j = 0; j < this.hauteur; j++) {
				habitants[i, j] = new CelluleGraphique (
				                          taille_habitants,
				                          i, j, ecran
				                      );
			}
		}
	}
	
	/*
	 * Dessine le monde à l'écran
	 */
	public void dessiner () {
		ecran.update_rect(0, 0, ecran.w, ecran.h);
	}
}
