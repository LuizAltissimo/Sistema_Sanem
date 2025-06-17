import { Pessoa } from './Pessoa';
import { Dependente } from './Dependente';

export class Beneficiario extends Pessoa {
    private renda: number;
    private dependentes: Dependente[];

    constructor(
        id: number = 0,
        nome: string = '',
        cpf: string = '',
        telefone: string = '',
        email: string = '',
        endereco: string = '',
        renda: number = 0
    ) {
        super(id, nome, cpf, telefone, email, endereco);
        this.renda = renda;
        this.dependentes = [];
    }

    public getRenda(): number {
        return this.renda;
    }

    public setRenda(renda: number): void {
        this.renda = renda;
    }

    public getDependentes(): Dependente[] {
        return this.dependentes;
    }

    public adicionarDependente(dependente: Dependente): void {
        this.dependentes.push(dependente);
    }

    public removerDependente(dependenteId: number): void {
        this.dependentes = this.dependentes.filter(d => d.getId() !== dependenteId);
    }
} 