import argparse
from collections import defaultdict
from functools import reduce
from lxml import etree
import graphviz

# =================================================
# 1. WCZYTYWANIE LOGU XES
# =================================================

def load_xes(path: str) -> list[list[str]]:
    with open(path, "rb") as f:
        content = f.read()

    # lxml z trybem recovery obsługuje obcięte / uszkodzone pliki XES
    parser = etree.XMLParser(recover=True, encoding="utf-8")
    root = etree.fromstring(content, parser)
    ns = "http://www.xes-standard.org"

    workflow_log = []
    for trace in root.findall(f"{{{ns}}}trace"):
        events = trace.findall(f"{{{ns}}}event")
        wt = []
        for event in events[0::2]:
            for child in event:
                if child.get("key") == "Activity":
                    wt.append(child.get("value"))
                    break
        if wt:
            workflow_log.append(wt)

    print(f"[LOG] Wczytano {len(workflow_log)} śladów.")
    return workflow_log


# =================================================
# 2. BUDOWANIE STRUKTURY SIECI HEURYSTYCZNEJ
# =================================================

def build_heuristic_net(workflow_log):
    w_net = {}
    ev_counter = defaultdict(int)
    edge_counter = defaultdict(int)

    for trace in workflow_log:
        for ev in trace:
            ev_counter[ev] += 1
        for i in range(len(trace) - 1):
            src, dst = trace[i], trace[i + 1]
            if src not in w_net:
                w_net[src] = set()
            w_net[src].add(dst)
            edge_counter[(src, dst)] += 1

    return w_net, dict(ev_counter), dict(edge_counter)


def detect_start_end(w_net):
    ev_source = set(w_net.keys())
    ev_target = reduce(lambda x, y: x | y, w_net.values(), set())
    start_set = ev_source - ev_target
    end_set = ev_target - ev_source
    return start_set, end_set


# =================================================
# 3. KOLORY NA PODSTAWIE CZĘSTOTLIWOŚCI
# =================================================

def freq_to_fillcolor(value, color_min, color_max, base_hex="#ff9933"):
    if color_max == color_min:
        alpha = 255
    else:
        ratio = float(color_max - value) / float(color_max - color_min)
        alpha = int(ratio * 200) + 30          # zakres 30–230
    return base_hex + format(alpha, "02x")


def edge_penwidth(count, edge_min, edge_max, min_pw=1.0, max_pw=8.0):
    if edge_max == edge_min:
        return min_pw
    ratio = (count - edge_min) / (edge_max - edge_min)
    return round(min_pw + ratio * (max_pw - min_pw), 2)


# =================================================
# 4. DIAGRAM 1 – PROSTA SIEĆ HEURYSTYCZNA
# =================================================

def draw_simple_net(w_net, output="diagram_1_prosta_siec"):
    G = graphviz.Digraph()
    G.graph_attr.update(rankdir="LR", splines="ortho")
    G.node_attr.update(shape="Mrecord")

    for event in w_net:
        G.node(event, style="rounded,filled", fillcolor="#ffffcc")
        for nxt in w_net[event]:
            G.edge(event, nxt)

    G.render(output, format="png", cleanup=True)
    print(f"[OK] {output}.png")


# =================================================
# 5. DIAGRAM 2 – Z CZĘSTOTLIWOŚCIAMI I KOLORAMI
# =================================================

def draw_colored_net(w_net, ev_counter, edge_counter, output="diagram_2_kolory_i_czestotliwosci"):
    color_min = min(ev_counter.values())
    color_max = max(ev_counter.values())
    edge_min = min(edge_counter.values())
    edge_max = max(edge_counter.values())

    G = graphviz.Digraph()
    G.graph_attr.update(rankdir="LR", splines="curved", nodesep="0.8")
    G.node_attr.update(shape="Mrecord")

    for event in w_net:
        fill = freq_to_fillcolor(ev_counter[event], color_min, color_max)
        label = f"{event}\n({ev_counter[event]}x)"
        G.node(event, label=label, style="rounded,filled", fillcolor=fill)

        for nxt in w_net[event]:
            count = edge_counter.get((event, nxt), 0)
            pw = str(edge_penwidth(count, edge_min, edge_max))
            G.edge(event, nxt, label=str(count), penwidth=pw)

    G.render(output, format="png", cleanup=True)
    print(f"[OK] {output}.png")


# =================================================
# 6. DIAGRAM 3 – ZE ZDARZENIAMI STARTOWYMI/KOŃCOWYMI
# =================================================

def draw_net_with_events(w_net, ev_counter, edge_counter,
                         output="diagram_3_start_koniec"):
    start_set, end_set = detect_start_end(w_net)
    print(f"[INFO] Start: {start_set}  |  End: {end_set}")

    color_min = min(ev_counter.values())
    color_max = max(ev_counter.values())
    edge_min = min(edge_counter.values())
    edge_max = max(edge_counter.values())

    G = graphviz.Digraph()
    G.graph_attr.update(rankdir="LR", splines="ortho", nodesep="0.8")
    G.node_attr.update(shape="Mrecord")

    for event in w_net:
        fill = freq_to_fillcolor(ev_counter[event], color_min, color_max)
        label = f"{event}\n({ev_counter[event]}x)"
        G.node(event, label=label, style="rounded,filled", fillcolor=fill)

        for nxt in w_net[event]:
            count = edge_counter.get((event, nxt), 0)
            pw = str(edge_penwidth(count, edge_min, edge_max))
            G.edge(event, nxt, label=str(count), penwidth=pw)

    # Węzeł startowy
    G.node("__start__", shape="circle", label="", style="filled",
           fillcolor="#2ecc71", width="0.5", fixedsize="true")
    for ev in start_set:
        G.edge("__start__", ev)

    # Węzły końcowe – kółko z podwójną obwódką (BPMN end event)
    for ev in end_set:
        G.node(ev, shape="doublecircle", label="", style="filled",
               fillcolor="#e74c3c", width="0.5", fixedsize="true")

    G.render(output, format="png", cleanup=True)
    print(f"[OK] {output}.png")


# =================================================
# 7. DIAGRAM 4 – FILTROWANIE PO PROGU
# =================================================

def draw_filtered_net(w_net, ev_counter, edge_counter,
                      threshold=5, output="diagram_4_filtrowanie"):

    start_set, end_set = detect_start_end(w_net)

    # Filtrujemy krawędzie
    filtered_edges = {
        (src, dst): cnt
        for (src, dst), cnt in edge_counter.items()
        if cnt >= threshold
    }
    # Zostawiamy tylko zdarzenia, które mają co najmniej jedną krawędź po filtrowaniu
    active_events = set()
    for (src, dst) in filtered_edges:
        active_events.add(src)
        active_events.add(dst)

    # Start/end zawsze zostają
    active_events |= start_set | end_set

    removed_events = set(ev_counter.keys()) - active_events
    if removed_events:
        print(f"[FILTR] Ukryte zdarzenia (< {threshold}x): {removed_events}")
    else:
        print(f"[FILTR] Wszystkie zdarzenia przekraczają próg {threshold}.")

    color_min = min((v for k, v in ev_counter.items() if k in active_events), default=1)
    color_max = max((v for k, v in ev_counter.items() if k in active_events), default=1)
    edge_min = min(filtered_edges.values(), default=1)
    edge_max = max(filtered_edges.values(), default=1)

    G = graphviz.Digraph()
    G.graph_attr.update(rankdir="LR", splines="ortho", nodesep="0.8")
    G.node_attr.update(shape="Mrecord")

    for event in active_events:
        if event in (start_set | end_set):
            continue
        fill = freq_to_fillcolor(ev_counter.get(event, 0), color_min, color_max)
        label = f"{event}\n({ev_counter.get(event, 0)}x)"
        G.node(event, label=label, style="rounded,filled", fillcolor=fill)

    for (src, dst), cnt in filtered_edges.items():
        pw = str(edge_penwidth(cnt, edge_min, edge_max))
        G.edge(src, dst, label=str(cnt), penwidth=pw)

    G.node("__start__", shape="circle", label="", style="filled",
           fillcolor="#2ecc71", width="0.5", fixedsize="true")
    for ev in start_set:
        if ev in active_events:
            G.edge("__start__", ev)

    for ev in end_set:
        if ev in active_events:
            G.node(ev, shape="doublecircle", label="", style="filled",
                   fillcolor="#e74c3c", width="0.5", fixedsize="true")

    G.render(output, format="png", cleanup=True)
    print(f"[OK] {output}.png  (próg filtrowania: {threshold})")


# =================================================
# 8. ALGORYTM ALFA (opcjonalny)
# =================================================

def build_alpha_relations(workflow_log):

    direct_succession = defaultdict(set)
    for trace in workflow_log:
        for i in range(len(trace) - 1):
            direct_succession[trace[i]].add(trace[i + 1])

    all_events = set(e for t in workflow_log for e in t)

    causality = defaultdict(set)
    parallel = set()

    for x in all_events:
        for y in all_events:
            xy = y in direct_succession.get(x, set())
            yx = x in direct_succession.get(y, set())
            if xy and not yx:
                causality[x].add(y)
            elif xy and yx:
                parallel.add((x, y))

    # Odwrócona przyczynowość (kto poprzedza dany węzeł)
    inv_causality = defaultdict(set)
    for x, targets in causality.items():
        for y in targets:
            inv_causality[y].add(x)

    start_set = set(e for t in workflow_log for e in [t[0]])
    end_set = set(e for t in workflow_log for e in [t[-1]])

    return direct_succession, causality, inv_causality, parallel, start_set, end_set


class BpmnGraph(graphviz.Digraph):

    def __init__(self):
        super().__init__()
        self.graph_attr.update(rankdir="LR", splines="ortho", nodesep="0.8")
        self.node_attr.update(shape="Mrecord")
        self.edge_attr.update(penwidth="2")

    def add_event_node(self, name, color="#2ecc71"):
        super().node(name, shape="circle", label="", style="filled",
                     fillcolor=color, width="0.5", fixedsize="true")

    def add_and_gateway(self, name):
        super().node(name, shape="diamond", width="0.6", height="0.6",
                     fixedsize="true", fontsize="28", label="+")

    def add_xor_gateway(self, name):
        super().node(name, shape="diamond", width="0.6", height="0.6",
                     fixedsize="true", fontsize="24", label="×")

    def add_and_split(self, source, targets):
        gw = f"ANDs_{source}_{'_'.join(sorted(targets))}"
        self.add_and_gateway(gw)
        super().edge(source, gw)
        for t in targets:
            super().edge(gw, t)

    def add_xor_split(self, source, targets):
        gw = f"XORs_{source}_{'_'.join(sorted(targets))}"
        self.add_xor_gateway(gw)
        super().edge(source, gw)
        for t in targets:
            super().edge(gw, t)

    def add_and_merge(self, sources, target):
        gw = f"ANDm_{'_'.join(sorted(sources))}_{target}"
        self.add_and_gateway(gw)
        super().edge(gw, target)
        for s in sources:
            super().edge(s, gw)

    def add_xor_merge(self, sources, target):
        gw = f"XORm_{'_'.join(sorted(sources))}_{target}"
        self.add_xor_gateway(gw)
        super().edge(gw, target)
        for s in sources:
            super().edge(s, gw)


def draw_alpha_bpmn(workflow_log, output="diagram_5_algorytm_alfa"):
    _, causality, inv_causality, parallel, start_set, end_set = \
        build_alpha_relations(workflow_log)

    G = BpmnGraph()

    # Bramki rozdzielające (split) – na podstawie przyczynowości
    for event, targets in causality.items():
        if len(targets) > 1:
            tup = frozenset(targets)
            if any((a, b) in parallel for a in tup for b in tup if a != b):
                G.add_and_split(event, targets)
            else:
                G.add_xor_split(event, targets)
        elif len(targets) == 1:
            G.edge(event, list(targets)[0])

    # Bramki scalające (merge) – na podstawie odwróconej przyczynowości
    for event, sources in inv_causality.items():
        if len(sources) > 1:
            tup = frozenset(sources)
            if any((a, b) in parallel for a in tup for b in tup if a != b):
                G.add_and_merge(sources, event)
            else:
                G.add_xor_merge(sources, event)

    # Zdarzenie startowe
    G.add_event_node("__start__", color="#2ecc71")
    if len(start_set) == 1:
        G.edge("__start__", list(start_set)[0])
    else:
        G.add_xor_split("__start__", start_set)

    # Zdarzenie końcowe
    G.add_event_node("__end__", color="#e74c3c")
    if len(end_set) == 1:
        G.edge(list(end_set)[0], "__end__")
    else:
        G.add_xor_merge(end_set, "__end__")

    G.render(output, format="png", cleanup=True)
    print(f"[OK] {output}.png")


# =================================================
# 9. MAIN
# =================================================

def main():
    parser = argparse.ArgumentParser(description="Process Mining – Mini Projekt")
    parser.add_argument("--xes", default="repairexample.xes",
                        help="Ścieżka do pliku .xes (domyślnie: repairexample.xes)")
    parser.add_argument("--threshold", type=int, default=5,
                        help="Próg filtrowania (domyślnie: 5)")
    parser.add_argument("--alpha", action="store_true",
                        help="Generuj też diagram algorytmu Alfa")
    args = parser.parse_args()

    print("=" * 55)
    print("  PROCESS MINING – repairexample.xes")
    print("=" * 55)

    # Wczytaj log
    log = load_xes(args.xes)

    # Zbuduj struktury
    w_net, ev_counter, edge_counter = build_heuristic_net(log)

    print("\n[INFO] Zdarzenia i ich częstotliwości:")
    for ev, cnt in sorted(ev_counter.items(), key=lambda x: -x[1]):
        print(f"  {ev:30s} {cnt:4d}x")

    print("\n[INFO] Generowanie diagramów...")

    # Diagram 1 – prosta sieć
    draw_simple_net(w_net)

    # Diagram 2 – kolory + częstotliwości węzłów i krawędzi
    draw_colored_net(w_net, ev_counter, edge_counter)

    # Diagram 3 – start/end + kolory + częstotliwości
    draw_net_with_events(w_net, ev_counter, edge_counter)

    # Diagram 4 – filtrowanie
    draw_filtered_net(w_net, ev_counter, edge_counter,
                      threshold=args.threshold)

    # Diagram 5 – algorytm Alfa (opcjonalny)
    if args.alpha:
        draw_alpha_bpmn(log)

    print("\n[GOTOWE] Wszystkie diagramy zostały zapisane jako pliki .png")


if __name__ == "__main__":
    main()
