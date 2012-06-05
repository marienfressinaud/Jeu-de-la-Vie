using SDL;

/* Représente l'état d'une cellule */
public enum Etat {
	INEXISTANTE,
	VIVANTE,
	MORTE
}

/* 
 * Une cellule est un organisme répondant aux lois suivantes :
 *     - Une cellule est soit morte, soit vivante (exit Schrödinger donc)
 *     - Une cellule vivante possède 2 ou 3 voisines vivantes, elle meurt sinon
 *     - Une cellule morte née si elle possède 3 voisines vivantes
 */
public class Cellule
{
	/* Signal envoyé lorsque la cellule change d'état */
	public signal void changementEtat (Etat e);

	/* L'état de la cellule */
	protected Etat _etat;
	public Etat etat {
		get {
			return _etat;
		}
		set {
			if (_etat != value) {
				_etat = value;
				changementEtat (value);
			}
		}
	}
	/* L'état suivant est calculé à partir du nombre de voisines */
	public Etat etat_suivant {
		get;
		set;
	}
	
	/* Représente le nombre de voisines de la cellule
	 * ._._._.
	 * |_|_|_|
	 * |_|X|_| <- sont considérées voisines de X toutes les cases autour
	 * |_|_|_|
	 */
	protected int _nb_voisines;
	public int nb_voisines {
		get {
			return _nb_voisines;
		}
		set {
			_nb_voisines = value;
			
			bool en_vie = estVivante ();
			
			// Tout l'algo de vie et de mort est implémenté là
			if (!en_vie && value == 3) {
				etat_suivant = Etat.VIVANTE;
			} else if (en_vie && !(value == 2 || value == 3)) {
				etat_suivant = Etat.MORTE;
			} else {
				etat_suivant = etat;
			}
		}
	}
	
	/* La taille d'une cellule */
	private uint16 _taille_cellule;
	public uint16 taille_cellule {
		get {
			return _taille_cellule;
		}
		set {
			if (value > 200) {
				value = 200;
			} else if (value < 1) {
				value = 1;
			}
			
			_taille_cellule = value;
		}
	}
	
	/* 
	 * Constructeur - par défaut, une cellule est inexistante
	 * @param taille_cellule représente la taille d'une cellule
	 */
	public Cellule (uint16 taille_cellule) {
		etat = Etat.INEXISTANTE;
		this.taille_cellule = taille_cellule;
	}
	
	/* 
	 * Les trois fonctions suivantes testent l'état de la cellule
	 * @return true si vivante (ou morte ou inexistante), false sinon
	 */
	public bool estVivante () {
		return etat == Etat.VIVANTE;
	}
	public bool estMorte () {
		return etat == Etat.MORTE;
	}
	public bool estInexistante () {
		return etat == Etat.INEXISTANTE;
	}
	
	/* 
	 * Les trois fonctions suivantes changent l'état d'une cellule
	 *     - on ne peut insuffler la vie qu'à une cellule non vivante
	 *     - on ne peut tuer une cellule que si elle est vivante
	 *     - on ne peut annihiler une cellule que si elle a déjà vécue
	 */
	public void insufflerVie () {
		if (!estVivante ()) {
			etat = Etat.VIVANTE;
		}
	}
	public void tuer () {
		if (estVivante ()) {
			etat = Etat.MORTE;
		}
	}
	public void annihiler () {
		if (!estInexistante ()) {
			etat = Etat.INEXISTANTE;
		}
	}
	
	/*
	 * Permet de valider l'état suivant en le faisant passer en état actuel
	 */
	public void validerEtat () {
		etat = etat_suivant;
	}
}

/* 
 * Une cellule graphique est la représentation d'une cellule à l'écran (SDL)
 */
public class CelluleGraphique : Cellule
{
	/* L'écran sur lequel se déroule le jeu */
	public weak Screen ecran;
	
	/* Le rectangle représenté à l'écran */
	public Rect rect_sur_ecran;
	
	/* Le rectangle représentant la cellule elle-même */
	public Rect self_rect;
	
	/* La surface qui accueille la couleur */
	public Surface surface;
	
	/* La couleur de la cellule */
	private uint32 _couleur;
	public uint32 couleur {
		get {
			return _couleur;
		}
		set {
			if (_couleur != value) {
				_couleur = value;
				surface.fill (null, _couleur);
			}
		}
	}
	
	/*
	 * Constructeur
	 * @param taille représente la taille de la cellule
	 * @param x, y la position de la cellule sur l'écran
	 * @param ecran l'écran sur lequel se déroule le jeu
	 */
	public CelluleGraphique (uint16 taille, int x, int y,
	                         SDL.Screen ecran) {
		base (taille);
		
		this.ecran = ecran;
		rect_sur_ecran.w = taille_cellule;
		rect_sur_ecran.h = taille_cellule;
		rect_sur_ecran.x = (int16)x * (int16)taille_cellule;
		rect_sur_ecran.y = (int16)y * (int16)taille_cellule;
		self_rect.w = taille_cellule;
		self_rect.h = taille_cellule;
		self_rect.x = 0;
		self_rect.y = 0;
		surface = new Surface.RGB (ecran.flags, taille_cellule,
		                           taille_cellule, 32, 0, 0, 0, 255);
		
		// Lorsque la cellule change d'état, on la recolorie
		this.changementEtat.connect ( (e) => {
			colorier ();
			surface.blit (self_rect, ecran, rect_sur_ecran);
		});
	}
	
	/*
	 * Permet de colorier la cellule en fonction de son état
	 * TODO Rendre possible le changement des couleurs par l'utilisateur
	 *    > à travers des jeux de couleurs ?
	 */
	private void colorier () {
		if (estVivante ()) {
			couleur = ecran.format.map_rgb (0, 255, 0);
		} else if (estMorte ()) {
			couleur = ecran.format.map_rgb (10, 10, 10);
		} else if (estInexistante ()) {
			couleur = ecran.format.map_rgb (0, 0, 0);
		}
	}
}
