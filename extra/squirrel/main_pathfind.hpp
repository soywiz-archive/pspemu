struct AStarNode {
	unsigned int opened;
	int x, y;
	int cost, cost_length, cost_heuristic;
	AStarNode *parent, *next;

	void init(int _x, int _y) {
		x = _x; y = _y;
		cost = cost_heuristic = cost_length = 0;
		next = parent = NULL;
	}
};

class AStarNodeList { public:
	AStarNode *first;
	
	AStarNodeList() {
		first = NULL;
	}

	void add(AStarNode *node) {
		if (first == NULL) {
			first = node;
			return;
		}

		if (node->cost <= first->cost) {
			node->next = first;
			first = node;
			return;
		}

		AStarNode *current = first;

		while (current->next != NULL) {
			if (node->cost <= current->next->cost) {
				node->next = current->next;
				current->next = node;
				return;
			}

			current = current->next;
		}

		current->next = node;
		return;
	}

	void remove(AStarNode *node) {
		AStarNode *current = first;

		if (node == first) {
			first = first->next;
			return;
		}

		while (current->next != NULL) {
			if (current->next == node) {
				current->next = node->next;
				return;
			}
			current = current->next;
		}
	}

	void update(AStarNode *node) {
		remove(node);
		add(node);
	}

	void clean() {
		AStarNode *current = first;
		while (current != NULL) {
			AStarNode *temp = current;
			current = temp->next;
			temp = NULL;
		}
		first = NULL;
	}

	bool has() { return (first != NULL); }
};

struct AStarPoint {
	int x, y;
};

class Pathfind { public:
	unsigned short w, h;
	unsigned short *data;
	unsigned char *blockInfo; int blockInfoLength;
	AStarNode *nodes;
	AStarNodeList *opened;
	AStarPoint *path; int path_length;
	unsigned int CLOSED, OPENED;
	int sx, sy, dx, dy;
	bool debug;

	Pathfind(unsigned short *data, unsigned char *blockInfo, int blockInfoLength, unsigned short w, unsigned short h, bool debug = 0) {
		this->blockInfo = blockInfo;
		this->blockInfoLength = blockInfoLength;
		this->data = data;
		this->w = w;
		this->h = h;
		this->CLOSED = 0;
		this->OPENED = 1;
		this->debug = debug;
		nodes  = new AStarNode[w * h];
		opened = new AStarNodeList();
		path   = new AStarPoint[w * h]; path_length = 0;
		prepareFirst();
	}
	
	void prepareFirst() {
		if (nodes == NULL) return;
		for (int n = 0; n < w * h; n++) {
			nodes[n].init(n % w, n / w);
			nodes[n].opened = CLOSED;
		}
	}

	void prepareEach() {
		prepareFirst();
		//if (nodes == NULL) return;
		//for (int n = 0; n < w * h; n++) nodes[n].opened = CLOSED;
		//for (int y = 0; y < h; y++) for (int x = 0; x < w; x++) nodes[y * w + x].reset();
		CLOSED += 2;
		OPENED += 2;
		//for (int n = 0; n < 16; n++) printf("%d", blockInfo[n]); printf("\n");
	}
	
	bool checkPos(int x, int y) { return (x >= 0) && (y >= 0) && (x < w) && (y < h); }
	bool check(int x, int y) {
		if (!checkPos(x, y)) return false;
		unsigned short type = data[y * w + x];
		//printf("%d:%d\n", type, blockInfo[type]);
		if (type >= blockInfoLength) return false;
		return (blockInfo[type] == 0);
	}
	bool checkNear(AStarNode *node, int x, int y) { return check(node->x + x, node->y + y); }
	
	int heuristic(int x, int y) { return abs(dx - x) + abs(dy - y); }

	void open(AStarNode *parent, int ix, int iy, int inc_cost_length) {
		int x = parent->x + ix, y = parent->y + iy;
		if (!check(x, y)) return;
		
		AStarNode *current = &nodes[y * w + x];
		if (current->opened == CLOSED) return;
		
		int cost_length    = parent->cost_length + inc_cost_length;
		int cost_heuristic = heuristic(x, y);
		if (x == dx && y == dy) cost_heuristic = cost_length = 0;
		
		int cost = cost_length + cost_heuristic;
		
		if (current->opened != OPENED) {
			current->opened = OPENED;
		} else {
			if (cost > current->cost) return;
			opened->remove(current);
		}
		
		current->parent         = parent;
		current->cost_length    = cost_length;
		current->cost_heuristic = cost_heuristic;
		current->cost           = cost;
		opened->add(current);
	}
	
	void next(AStarNode *current, bool diagonals) {
		open(current, -1,  0, 10);
		open(current,  1,  0, 10);
		open(current,  0, -1, 10);
		open(current,  0,  1, 10);

		if (diagonals) {
			if (checkNear(current, -1, 0) && checkNear(current, 0, -1)) open(current, -1, -1, 14);
			if (checkNear(current,  1, 0) && checkNear(current, 0, -1)) open(current,  1, -1, 14);
			if (checkNear(current, -1, 0) && checkNear(current, 0,  1)) open(current, -1,  1, 14);
			if (checkNear(current,  1, 0) && checkNear(current, 0,  1)) open(current,  1,  1, 14);
		}
	}

	bool find(int _sx, int _sy, int _dx, int _dy, bool diagonals = true) {
		AStarNode *current;
		bool found = false;
		
		prepareEach();
		
		if (debug) printf("TileMap.pathFind((%d, %d), (%d, %d), [%d])\n", _sx, _sy, _dx, _dy, diagonals);

		// Check constraints.
		if (!check(this->sx = _sx, this->sy = _sy)) {
			if (debug) printf("Invalid position/block for start (%d, %d).\n", sx, sy);
			return false;
		}
		if (!check(this->dx = _dx, this->dy = _dy)) {
			if (debug) printf("Invalid position/block for end (%d, %d).\n", dx, dy);
			return false;
		}
		
		opened->clean();
		current = &nodes[sy * w + sx];
		opened->add(current);
		current->opened = OPENED;

		while (opened->has()) {
			current = opened->first;
			opened->remove(current);
			if ((current->x == dx) && (current->y == dy)) { found = true; break; }
			next(current, diagonals);
			current->opened = CLOSED;
		}
		
		if (!found) {
			if (debug) printf("Not found path!\n");
			return false;
		}

		path_length = 0;
		while (current) {
			//retlist ~= new Point(current.x, current.y);
			if (debug) printf("(%d,%d)\n", current->x, current->y);
			path[path_length].x = current->x;
			path[path_length].y = current->y;
			path_length++;
			current = current->parent;
		}
		
		return true;
	}

	~Pathfind() {
		if (nodes  != NULL) delete nodes;
		if (opened != NULL) delete opened;
		if (path   != NULL) delete path;
	}
};
