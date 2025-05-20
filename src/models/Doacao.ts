import { Base } from './Base';
import { Voluntario } from './Voluntario';
import { Beneficiario } from './Beneficiario';
import { Item } from './Item';

export class Doacao extends Base {
    private voluntario: Voluntario;
    private beneficiario: Beneficiario;
    private dataDoacao: Date;
    private itens: Item[];
    private tipoDoacao: string;
    private status: string;
    private observacoes: string;

    constructor(
        id: number = 0,
        voluntario: Voluntario,
        beneficiario: Beneficiario,
        itens: Item[] = [],
        dataDoacao: Date = new Date(),
        tipoDoacao: string = 'RECEBIDA',
        status: string = 'PENDENTE',
        observacoes: string = ''
    ) {
        super(id);
        this.voluntario = voluntario;
        this.beneficiario = beneficiario;
        this.dataDoacao = dataDoacao;
        this.itens = itens;
        this.tipoDoacao = tipoDoacao;
        this.status = status;
        this.observacoes = observacoes;
    }

    public getVoluntario(): Voluntario {
        return this.voluntario;
    }

    public setVoluntario(voluntario: Voluntario): void {
        this.voluntario = voluntario;
    }

    public getBeneficiario(): Beneficiario {
        return this.beneficiario;
    }

    public setBeneficiario(beneficiario: Beneficiario): void {
        this.beneficiario = beneficiario;
    }

    public getDataDoacao(): Date {
        return this.dataDoacao;
    }

    public setDataDoacao(dataDoacao: Date): void {
        this.dataDoacao = dataDoacao;
    }

    public getItens(): Item[] {
        return this.itens;
    }

    public adicionarItem(item: Item): void {
        this.itens.push(item);
    }

    public removerItem(itemId: number): void {
        this.itens = this.itens.filter(i => i.getId() !== itemId);
    }

    public getTipoDoacao(): string {
        return this.tipoDoacao;
    }

    public setTipoDoacao(tipoDoacao: string): void {
        this.tipoDoacao = tipoDoacao;
    }

    public getStatus(): string {
        return this.status;
    }

    public setStatus(status: string): void {
        this.status = status;
    }

    public getObservacoes(): string {
        return this.observacoes;
    }

    public setObservacoes(observacoes: string): void {
        this.observacoes = observacoes;
    }
} 